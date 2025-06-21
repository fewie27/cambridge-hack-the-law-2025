import os
import torch
import numpy as np
from transformers import AutoTokenizer, AutoModel
from chromadb import PersistentClient

# === Configuration ===
MODEL_NAME = "nlpaueb/legal-bert-base-uncased"
DATA_DIR = os.path.join(os.path.dirname(__file__), 'chroma_data')
collection_name = "legal_cases"

# === Load tokenizer, model, and Chroma client ===
device = torch.device("mps" if torch.has_mps else "cpu")  # Use GPU if on Mac M1/M2
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModel.from_pretrained(MODEL_NAME).to(device)
model.eval()

client = PersistentClient(path=DATA_DIR)
collection = client.get_collection(collection_name)

# === Embed prompt ===
def embed_text(text: str) -> list:
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
    inputs = {k: v.to(device) for k, v in inputs.items()}
    with torch.no_grad():
        outputs = model(**inputs)
        last_hidden_state = outputs.last_hidden_state
        attention_mask = inputs['attention_mask']
        mask_expanded = attention_mask.unsqueeze(-1).expand(last_hidden_state.size()).float()
        summed = torch.sum(last_hidden_state * mask_expanded, 1)
        counts = torch.clamp(mask_expanded.sum(1), min=1e-9)
        mean_pooled = summed / counts
    embedding = mean_pooled[0].cpu().numpy()
    embedding = embedding / np.linalg.norm(embedding)
    return embedding.tolist()

# === Your prompt ===
query_prompt = """
I’m working on a case representing Fenoscadia Limited, a mining company from Ticadia that was operating in Kronos under an 80-year concession to extract lindoro, a rare earth metal. In 2016, Kronos passed a decree that revoked Fenoscadia’s license and terminated the concession agreement, citing environmental concerns. The government had funded a study that suggested lindoro mining contaminated the Rhea River and caused health issues, although the study didn’t conclusively prove this.
Kronos is now filing an environmental counterclaim in the ongoing arbitration, seeking at least USD 150 million for environmental damage, health costs, and water purification.

Can you help me analyze how to challenge Kronos’s environmental counterclaim, especially in terms of jurisdiction, admissibility, and merits?
"""

# === Embed and query ===
query_embedding = embed_text(query_prompt)

results = collection.query(
    query_embeddings=[query_embedding],
    n_results=5  # You can increase this if you want more results
)

# === Show results ===
for i, doc in enumerate(results['documents'][0]):
    print(f"\n🔹 Result #{i+1}")
    print(f"Chunk: {doc[:500]}...")  # Limit long texts
    print(f"Metadata: {results['metadatas'][0][i]}")