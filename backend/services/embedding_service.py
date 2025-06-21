import os
import torch
import numpy as np
from transformers import AutoTokenizer, AutoModel
from chromadb import PersistentClient

# === Configuration ===
MODEL_NAME = "nlpaueb/legal-bert-base-uncased"
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'database', 'chroma_data')
COLLECTION_NAME = "legal_cases"

class EmbeddingService:
    def __init__(self):
        """Initialize embedding service and load models"""
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

    def search_similar_cases(self, user_prompt: str, top_k: int = 10):
        """
        Search for similar cases using semantic search.
        Returns a list of dictionaries with case metadata and matching scores.
        """
        if self.collection.count() == 0:
            return {
                "documents": [],
                "metadatas": [],
                "distances": []
            }

        query_embedding = self._embed_text(user_prompt)
        
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=min(top_k, self.collection.count()) 
        )
        return results 