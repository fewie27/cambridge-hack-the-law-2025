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

    def _read_case_file(self, source_file: str) -> dict:
        """Read case file content from a JSON file."""
        base_cases_path = os.path.join(os.path.dirname(__file__), '..', 'database', 'cases')
        full_path = os.path.join(base_cases_path, source_file)
        if not os.path.exists(full_path):
            return {"error": "File not found", "path": full_path}
        try:
            with open(full_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            return {"error": f"Failed to read or parse file: {e}", "path": full_path}

    def _analyze_with_gemini(self, user_prompt: str, cases_data: list) -> dict:
        """Analyze cases with Gemini and return structured arguments."""
        case_details = []
        for case in cases_data:
            meta = case['metadata']
            source_file = meta.get('source_file', 'N/A')
            title = meta.get('Title') or meta.get('title') or source_file
            full_data = meta.get('full_case_data', {})
            summary = full_data.get('summary') or full_data.get('headnote') or ''
            if summary:
                summary = summary[:500] + ('...' if len(summary) > 500 else '')
            chunk = case['document'][:500] + ('...' if len(case['document']) > 500 else '')
            case_text = f"Title: {title}\nSource File: {source_file}\n"
            if summary:
                case_text += f"Summary: {summary}\n"
            case_text += f"Relevant Excerpt: {chunk}"
            case_details.append(case_text)
        cases_text = "\n---\n".join(case_details)
        prompt = f"""
You are a legal analysis expert. Your task is to analyze a user's legal query and a set of relevant case documents. You must identify key arguments, but only those that are directly supported by the provided case documents. Each argument must be derived from the content of at least one case, and must reference at least one of the provided case documents.

**User's Query:**
"{user_prompt}"

**Relevant Case Documents:**
{cases_text}

**Your Task:**
Generate a JSON response with two main keys: "strengths" and "weaknesses".
Each key should contain a list of arguments.
Each argument object in the list should have two keys:
1. "argument": A string describing the argument you have formulated, based on the content of the case(s).
2. "case_references": A list of case identifiers (the source_file from the case data) that support this argument. This list must never be empty.

The response should only be the JSON object, without any additional text or markdown.
"""
        try:
            response = self.gen_model.generate_content(prompt)
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
        print(results)
        cases_for_gemini = []
        if results and results['metadatas']:
            for i, meta in enumerate(results['metadatas'][0]):
                source_file = meta.get("source_file")
                if source_file:
                    full_case_data = self._read_case_file(source_file)
                    results['metadatas'][0][i]['full_case_data'] = full_case_data
                    cases_for_gemini.append({
                        "document": results['documents'][0][i],
                        "metadata": results['metadatas'][0][i],
                        "distance": results['distances'][0][i]
                    })
        if not cases_for_gemini:
            print("No cases for gemini analysis found.")
            return {"strengths": [], "weaknesses": []}
        structured_analysis = self._analyze_with_gemini(user_prompt, cases_for_gemini)
        case_lookup = {case['metadata']['source_file']: case for case in cases_for_gemini}
        def process_arguments(arg_list):
            processed_list = []
            for arg in arg_list:
                # Only keep arguments with at least one valid case reference
                valid_refs = [source_file for source_file in arg.get("case_references", []) if source_file in case_lookup]
                if not valid_refs:
                    continue
                processed_arg = {
                    "argument": arg.get("argument"),
                    "case_references": [case_lookup[source_file] for source_file in valid_refs]
                }
                processed_list.append(processed_arg)
            return processed_list
        final_result = {
            "strengths": process_arguments(structured_analysis.get("strengths", [])),
            "weaknesses": process_arguments(structured_analysis.get("weaknesses", []))
        }
        return final_result 