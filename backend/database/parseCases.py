import os
import json
from uuid import uuid4
from typing import List

from transformers import AutoTokenizer, AutoModel
import torch
import numpy as np

from chromadb import PersistentClient

# === Configuration ===
FOLDER_PATH = "cases"
MAX_TOKENS = 500
OVERLAP = 100
MODEL_NAME = "nlpaueb/legal-bert-base-uncased"
DATA_DIR = os.path.join(os.path.dirname(__file__), 'chroma_data')

# === Initialize Chroma client and collection ===
client = PersistentClient(path=DATA_DIR)
collection_name = "legal_cases"

if collection_name in [c.name for c in client.list_collections()]:
    collection = client.get_collection(collection_name)
else:
    collection = client.create_collection(name=collection_name)

# === Load model and tokenizer ===
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModel.from_pretrained(MODEL_NAME)
model.eval()


# === Utility functions ===
def chunk_text(text: str, max_tokens: int = MAX_TOKENS, overlap: int = OVERLAP) -> List[str]:
    words = text.split()
    chunks = []
    i = 0
    while i < len(words):
        chunk_words = words[i:i + max_tokens]
        chunk = " ".join(chunk_words)

        token_count = len(tokenizer.tokenize(chunk))
        while token_count > max_tokens and len(chunk_words) > 10:
            chunk_words = chunk_words[:-10]
            chunk = " ".join(chunk_words)
            token_count = len(tokenizer.tokenize(chunk))

        chunks.append(chunk)
        i += max_tokens - overlap
    return chunks


def embed_text(text: str) -> List[float]:
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
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


def normalize_metadata(value):
    if isinstance(value, list):
        return ", ".join(map(str, value))
    return value


# === Core file processing ===
def process_case_file(file_path: str):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    case_metadata = {
        "Identifier": normalize_metadata(data.get("Identifier")),
        "Title": normalize_metadata(data.get("Title")),
        "CaseNumber": normalize_metadata(data.get("CaseNumber")),
        "Industries": normalize_metadata(data.get("Industries", [])),
        "Status": normalize_metadata(data.get("Status")),
        "PartyNationalities": normalize_metadata(data.get("PartyNationalities", [])),
        "Institution": normalize_metadata(data.get("Institution")),
        "RulesOfArbitration": normalize_metadata(data.get("RulesOfArbitration", [])),
        "ApplicableTreaties": normalize_metadata(data.get("ApplicableTreaties", [])),
    }

    for decision in data.get("Decisions", []):
        content = decision.get("Content")
        if not content:
            continue

        decision_metadata = {
            "DecisionTitle": normalize_metadata(decision.get("Title")),
            "DecisionType": normalize_metadata(decision.get("Type")),
            "DecisionDate": normalize_metadata(decision.get("Date")),
        }

        chunks = chunk_text(content)
        for i, chunk in enumerate(chunks):
            embedding = embed_text(chunk)
            metadata = {
                **case_metadata,
                **decision_metadata,
                "chunk_index": i,
                "chunk": chunk,
                "source_file": os.path.basename(file_path)
            }

            collection.add(
                documents=[chunk],
                embeddings=[embedding],
                metadatas=[metadata],
                ids=[str(uuid4())]
            )


def process_all_files(folder_path: str):
    for file in os.listdir(folder_path):
        if file.endswith(".json"):
            file_path = os.path.join(folder_path, file)
            try:
                process_case_file(file_path)
                print(f"✅ Processed and inserted {file}")
            except Exception as e:
                print(f"❌ Error processing {file}: {e}")


# === MAIN ===
if __name__ == "__main__":
    process_all_files(FOLDER_PATH)
    collection.persist()
    print("✅ All embeddings processed and stored in Chroma DB.")
