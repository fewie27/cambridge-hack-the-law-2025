import os
import torch
import numpy as np
from transformers import AutoTokenizer, AutoModel
from chromadb import PersistentClient
import json
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# === Configuration ===
MODEL_NAME = "nlpaueb/legal-bert-base-uncased"
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'database', 'chroma_data')
COLLECTION_NAME = "legal_cases"

class EmbeddingService:
    def __init__(self):
        """Initialize embedding service and load models"""
        # Configure Gemini API
        try:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
            self.gen_model = genai.GenerativeModel('gemini-1.5-flash')
        except Exception as e:
            # Handle cases where API key is not set
            raise RuntimeError("GEMINI_API_KEY environment variable not set.") from e

        self.device = torch.device("mps" if torch.has_mps else "cpu")
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        self.model = AutoModel.from_pretrained(MODEL_NAME).to(self.device)
        self.model.eval()

        # Initialize Chroma client and get collection
        self.client = PersistentClient(path=DATA_DIR)
        self.collection = self.client.get_or_create_collection(COLLECTION_NAME)

    def _embed_text(self, text: str) -> list:
        """Embed text using the loaded model"""
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
        inputs = {k: v.to(self.device) for k, v in inputs.items()}
        with torch.no_grad():
            outputs = self.model(**inputs)
            last_hidden_state = outputs.last_hidden_state
            attention_mask = inputs['attention_mask']
            mask_expanded = attention_mask.unsqueeze(-1).expand(last_hidden_state.size()).float()
            summed = torch.sum(last_hidden_state * mask_expanded, 1)
            counts = torch.clamp(mask_expanded.sum(1), min=1e-9)
            mean_pooled = summed / counts
        embedding = mean_pooled[0].cpu().numpy()
        embedding = embedding / np.linalg.norm(embedding)
        return embedding.tolist()

    def _read_case_file(self, file_path: str) -> dict:
        """Read case file content from a JSON file."""
        # Note: The file_path from metadata is just the filename, e.g., "13.json"
        # We need to construct the full path.
        base_cases_path = os.path.join(os.path.dirname(__file__), '..', 'database', 'cases')
        full_path = os.path.join(base_cases_path, file_path)

        if not os.path.exists(full_path):
            # You might want to log this situation
            return {"error": "File not found", "path": full_path}

        try:
            with open(full_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            # Log the error
            return {"error": f"Failed to read or parse file: {e}", "path": full_path}

    def _analyze_with_gemini(self, user_prompt: str, cases_data: list) -> dict:
        """Analyze cases with Gemini and return structured arguments."""
        
        case_details = []
        for case in cases_data:
            # case is a dict with 'document', 'metadata', 'distance'
            file_path = case['metadata'].get('file_path', 'N/A')
            full_data = case['metadata'].get('full_case_data', {})
            # We'll send the full case text if available, otherwise the chunk.
            content = json.dumps(full_data) if full_data else case['document']
            case_details.append(f"Case File: \"{file_path}\"\nContent:\n{content}")
        
        cases_text = "\n---\n".join(case_details)

        prompt = f"""
                You are a legal analysis expert. Your task is to analyze a user's legal query and a set of relevant case documents. Based on this information, you must identify key arguments, classify them as strengths or weaknesses for the user's position, and group the provided case documents under the most relevant argument.

                **User's Query:**
                "{user_prompt}"

                **Relevant Case Documents:**
                {cases_text}

                **Your Task:**
                Generate a JSON response with two main keys: "strengths" and "weaknesses".
                Each key should contain a list of arguments.
                Each argument object in the list should have two keys:
                1. "argument": A string describing the argument you have formulated.
                2. "case_references": A list of case identifiers (the file paths from the case data) that support this argument.

                The response should only be the JSON object, without any additional text or markdown.
                """
        
        try:
            response = self.gen_model.generate_content(prompt)
            # Clean up the response to extract only the JSON part.
            cleaned_response = response.text.strip().replace("```json", "").replace("```", "")
            return json.loads(cleaned_response)
        except Exception as e:
            print(f"Error calling Gemini or parsing response: {e}")
            return {"strengths": [], "weaknesses": []}

    def search_similar_cases(self, user_prompt: str, top_k: int = 10):
        """
        Search for similar cases, then use Gemini to analyze and structure the results.
        """
        if self.collection.count() == 0:
            return {"strengths": [], "weaknesses": []}

        query_embedding = self._embed_text(user_prompt)
        
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=min(top_k, self.collection.count()) 
        )
        
        # Enrich results and prepare for Gemini
        cases_for_gemini = []
        if results and results['metadatas']:
            for i, meta in enumerate(results['metadatas'][0]):
                file_path = meta.get("file_path")
                if file_path:
                    full_case_data = self._read_case_file(file_path)
                    results['metadatas'][0][i]['full_case_data'] = full_case_data
                    
                    # Consolidate data for each case
                    cases_for_gemini.append({
                        "document": results['documents'][0][i],
                        "metadata": results['metadatas'][0][i],
                        "distance": results['distances'][0][i]
                    })

        if not cases_for_gemini:
            return {"strengths": [], "weaknesses": []}

        # Analyze with Gemini
        structured_analysis = self._analyze_with_gemini(user_prompt, cases_for_gemini)

        # We need to map the file paths from Gemini's response back to the full case data
        # so the endpoint can create CaseReference objects.
        
        # Create a lookup map
        case_lookup = {case['metadata']['file_path']: case for case in cases_for_gemini}

        def process_arguments(arg_list):
            processed_list = []
            for arg in arg_list:
                processed_arg = {
                    "argument": arg.get("argument"),
                    "case_references": []
                }
                for file_ref in arg.get("case_references", []):
                    if file_ref in case_lookup:
                        processed_arg["case_references"].append(case_lookup[file_ref])
                processed_list.append(processed_arg)
            return processed_list

        final_result = {
            "strengths": process_arguments(structured_analysis.get("strengths", [])),
            "weaknesses": process_arguments(structured_analysis.get("weaknesses", []))
        }

        return final_result 