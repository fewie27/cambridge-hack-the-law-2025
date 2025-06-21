import os
from sentence_transformers import SentenceTransformer
import chromadb
import json
import google.generativeai as genai
from dotenv import load_dotenv
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

# Load environment variables from .env file
load_dotenv()

# === Configuration ===
# Ensure this is the same model used in parseCases.py
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'database', 'chroma_data')
COLLECTION_NAME = "legal_cases"

class EmbeddingService:
    def __init__(self):
        """Initialize embedding service and load models"""
        # Configure Gemini API
        try:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
            self.gen_model = genai.GenerativeModel('gemini-1.5-pro')
        except Exception as e:
            # Handle cases where API key is not set
            raise RuntimeError("GEMINI_API_KEY environment variable not set.") from e

        # Load the SentenceTransformer model
        self.model = SentenceTransformer(MODEL_NAME)

        # Initialize Chroma client and get collection
        self.client = chromadb.PersistentClient(path=DATA_DIR)
        self.collection = self.client.get_or_create_collection(COLLECTION_NAME)

    def _embed_text(self, text: str) -> list:
        """Embed text using the SentenceTransformer model."""
        embedding = self.model.encode(text, show_progress_bar=False, normalize_embeddings=True)
        return embedding.tolist()

    def _fix_mojibake(self, text: str) -> str:
        """Attempt to fix common UTF-8 mis-encoding issues (mojibake)."""
        if not isinstance(text, str):
            return text
        try:
            # This sequence can repair strings that were encoded in UTF-8
            # but were incorrectly read as latin-1 or a similar single-byte encoding.
            # e.g., "Fenoscadiaâ\x80\x99s" -> "Fenoscadia's"
            return text.encode('latin1').decode('utf-8')
        except (UnicodeEncodeError, UnicodeDecodeError):
            # The string is likely already correctly encoded or in a different format.
            return text

    def _read_case_file(self, source_file: str) -> dict:
        """Read case file content from a JSON file."""
        base_cases_path = os.path.join(os.path.dirname(__file__), '..', 'database', 'cases')
        full_path = os.path.join(base_cases_path, source_file)
        if not os.path.exists(full_path):
            return {"error": "File not found", "path": full_path}
        try:
            # Specify UTF-8 encoding to prevent character issues
            with open(full_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            return {"error": f"Failed to read or parse file: {e}", "path": full_path}

    def extract_metadata_from_prompt(self, user_prompt: str) -> dict:
        """Extracts claimant, respondent, and year from a user prompt using Gemini."""
        prompt = f"""
From the following text, extract the claimant, the respondent, and the year of the case. 
Return the information as a JSON object with the keys "claimant", "respondent", and "case_year".
If a value is not found, set it to null.

Text: "{user_prompt}"

JSON:
"""
        try:
            response = self.gen_model.generate_content(prompt)
            # Clean up potential markdown and parse
            cleaned_response = response.text.strip().replace("```json", "").replace("```", "")
            metadata = json.loads(cleaned_response)
            return {
                "claimant": metadata.get("claimant"),
                "respondent": metadata.get("respondent"),
                "case_year": metadata.get("case_year")
            }
        except Exception as e:
            print(f"Error extracting metadata from prompt: {e}")
            return {"claimant": None, "respondent": None, "case_year": None}

    def _analyze_with_gemini(self, user_prompt: str, cases_data: list) -> dict:
        """Analyze cases with Gemini and return structured arguments."""
        case_details = []
        for case in cases_data:
            meta = case['metadata']
            source_file = meta.get('source_file', 'N/A')
            title = meta.get('Title') or meta.get('title') or source_file
            status = meta.get('Status', '')
            decision_type = meta.get('DecisionType', '')
            institution = meta.get('Institution', '')
            full_data = meta.get('full_case_data', {})
            summary = full_data.get('summary') or full_data.get('headnote') or ''
            if summary:
                summary = summary[:500] + ('...' if len(summary) > 500 else '')
            chunk = case['document'][:1000] + ('...' if len(case['document']) > 1000 else '')
            case_text = f"Title: {title}\nSource File: {source_file}\n"
            if status:
                case_text += f"Status: {status}\n"
            if decision_type:
                case_text += f"Decision Type: {decision_type}\n"
            if institution:
                case_text += f"Institution: {institution}\n"
            if summary:
                case_text += f"Summary: {summary}\n"
            case_text += f"Relevant Excerpt: {chunk}"
            case_details.append(case_text)
        cases_text = "\n---\n".join(case_details)
        prompt = f"""
You are a legal analysis expert. Your task is to analyze a user's legal query and a set of relevant case documents. 
Your goal is to generate a diverse set of arguments, covering as many of the provided cases as possible.

You must identify key arguments, but only those that are directly supported by the provided case documents. 
Each argument must be derived from the content of at least one case, and must reference at least one of the provided case documents.

For both strengths and weaknesses, always try to find at least one argument if possible. Strive to create multiple distinct arguments for each category if the documents support it.

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

If you cannot find a clear weakness, provide the closest possible counterpoint or limitation you can infer from the cases.

The response should only be the JSON object, without any additional text or markdown.
"""
        try:
            response = self.gen_model.generate_content(prompt)
            cleaned_response = response.text.strip().replace("```json", "").replace("```", "")
            return json.loads(cleaned_response)
        except Exception as e:
            print(f"Error calling Gemini or parsing response: {e}")
            return {"strengths": [], "weaknesses": []}

    def search_similar_cases(self, user_prompt: str, top_k: int = 10, claimant: str = None, respondent: str = None, case_year: int = None):
        """
        Search for similar cases using a two-stage process:
        1. Broad semantic search based on the user prompt.
        2. Rescore the top results based on metadata similarity.
        """
        if self.collection.count() == 0:
            return {"strengths": [], "weaknesses": []}

        # Stage 1: Broad semantic search
        query_embedding = self._embed_text(user_prompt)
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=min(top_k * 10, self.collection.count())  # Fetch a large pool for rescoring
        )
        
        # === FIX ENCODING ISSUES AT THE SOURCE ===
        # The data from ChromaDB might have encoding issues (mojibake).
        # We fix it here before it's used anywhere else.
        if results['documents'] and results['documents'][0]:
            results['documents'][0] = [self._fix_mojibake(doc) for doc in results['documents'][0]]
        
        if results['metadatas'] and results['metadatas'][0]:
            fixed_metadatas = []
            for meta in results['metadatas'][0]:
                fixed_meta = {}
                for key, value in meta.items():
                    if isinstance(value, str):
                        fixed_meta[key] = self._fix_mojibake(value)
                    elif isinstance(value, list):
                        # Also fix strings within lists
                        fixed_meta[key] = [self._fix_mojibake(item) if isinstance(item, str) else item for item in value]
                    else:
                        fixed_meta[key] = value
                fixed_metadatas.append(fixed_meta)
            results['metadatas'][0] = fixed_metadatas
        
        # Stage 2: Metadata Rescoring
        if claimant or respondent or case_year:
            # Create the query's metadata string
            query_meta_parts = []
            if claimant: query_meta_parts.append(f"Claimant: {claimant}")
            if respondent: query_meta_parts.append(f"Respondent: {respondent}")
            if case_year: query_meta_parts.append(f"Year: {case_year}")
            query_meta_str = ". ".join(query_meta_parts)
            query_meta_embedding = self._embed_text(query_meta_str)

            # Create metadata strings for each result
            result_meta_strs = []
            for meta in results['metadatas'][0]:
                meta_parts = []
                if meta.get("PartyNationalities"): meta_parts.append(f"Parties: {meta['PartyNationalities']}")
                if meta.get("DecisionDate"): meta_parts.append(f"Date: {meta['DecisionDate']}")
                result_meta_strs.append(". ".join(meta_parts))

            # Embed all result metadata strings at once for efficiency
            result_meta_embeddings = self.model.encode(result_meta_strs)
            
            # Calculate cosine similarity between query metadata and result metadata
            meta_similarities = cosine_similarity([query_meta_embedding], result_meta_embeddings)[0]
            
            # Combine semantic distance and metadata similarity into a new score
            # We convert semantic distance to similarity (1 - distance)
            semantic_similarities = [1 - dist for dist in results['distances'][0]]
            
            # Weighted average: 70% semantic, 30% metadata. Tune as needed.
            combined_scores = (0.7 * np.array(semantic_similarities)) + (0.3 * np.array(meta_similarities))
            
            # Get the indices of the top_k results based on the new combined score
            top_indices = np.argsort(combined_scores)[::-1][:top_k]

        else:
            # If no metadata is provided, just use the top semantic results
            top_indices = list(range(top_k))

        # Build the final list of cases for Gemini
        cases_for_gemini = []
        for i in top_indices:
            meta = results['metadatas'][0][i]
            source_file = meta.get("source_file")
            if source_file:
                full_case_data = self._read_case_file(source_file)
                meta['full_case_data'] = full_case_data
                cases_for_gemini.append({
                    "document": results['documents'][0][i],
                    "metadata": meta,
                    "distance": results['distances'][0][i] 
                })

        if not cases_for_gemini:
            print("No cases for Gemini analysis found after rescoring.")
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