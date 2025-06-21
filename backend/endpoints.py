from datetime import datetime, date
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

# Import generated models
from models import HealthResponse, Argument, CaseReference, AnalysisResponse, AddCaseRequest

# Import embedding service
from services.embedding_service import EmbeddingService

# Create router for API endpoints
api_router = APIRouter(prefix="/api/v1", tags=["API"])

# Initialize embedding service
embedding_service = EmbeddingService()

@api_router.post("/add_case", response_model=AnalysisResponse)
async def add_case(request: AddCaseRequest):
    """Add a new case with user prompt analysis using semantic search"""
    if not request.user_prompt or len(request.user_prompt.strip()) == 0:
        raise HTTPException(status_code=400, detail="User prompt cannot be empty")
    
    if len(request.user_prompt) > 1000:
        raise HTTPException(status_code=400, detail="User prompt too long (max 1000 characters)")
    
    try:
        # Generate a case ID
        import uuid
        case_id = f"CASE-{uuid.uuid4().hex[:8].upper()}"
        
        # Use the embedding service to find similar cases
        search_results = embedding_service.search_similar_cases(request.user_prompt, top_k=5)
        
        # Process results into AnalysisResponse format
        strengths = []
        if search_results and search_results['documents']:
            # Assume all results are strengths for now
            arguments = {}
            
            docs = search_results['documents'][0]
            metadatas = search_results['metadatas'][0]
            distances = search_results['distances'][0]

            for i in range(len(docs)):
                doc = docs[i]
                meta = metadatas[i]
                distance = distances[i]

                # Create a CaseReference from metadata
                case_ref = CaseReference(
                    caseIdentifier=meta.get("case_id", "N/A"),
                    title=meta.get("title", "Unknown Title"),
                    Date=date.fromisoformat(meta["date"]) if meta.get("date") else None,
                    matchingDegree=1 - distance,  # Convert distance to similarity
                    fileReference=meta.get("file_path", "N/A")
                )

                # Group by document/argument
                if doc not in arguments:
                    arguments[doc] = Argument(argument=doc, case_references=[])
                arguments[doc].case_references.append(case_ref)

            strengths = list(arguments.values())

        # For now, weaknesses list is empty as we don't have a mechanism to distinguish them
        weaknesses = []
        
        return AnalysisResponse(
            caseId=case_id,
            strengths=strengths,
            weaknesses=weaknesses
        )
        
    except Exception as e:
        print(f"Error in add_case: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 