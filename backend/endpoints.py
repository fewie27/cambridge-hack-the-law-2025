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
        
        # Use the embedding service to find and analyze similar cases
        structured_analysis = embedding_service.search_similar_cases(request.user_prompt, top_k=5)
        
        def convert_to_arguments(analysis_list):
            """Converts a list of dicts into a list of Argument Pydantic models."""
            if not analysis_list:
                return []
            
            output_args = []
            for item in analysis_list:
                case_refs = []
                for ref_data in item.get("case_references", []):
                    meta = ref_data.get("metadata", {})
                    full_case_data = meta.get("full_case_data", {})
                    title = full_case_data.get("name", "Unknown Title")
                    
                    case_refs.append(CaseReference(
                        caseIdentifier=meta.get("case_id", "N/A"),
                        title=title,
                        Date=date.fromisoformat(meta["date"]) if meta.get("date") else None,
                        matchingDegree=1 - ref_data.get("distance", 1.0), # Convert distance to similarity
                        fileReference=meta.get("file_path", "N/A")
                    ))
                
                output_args.append(Argument(
                    argument=item.get("argument", "No argument provided."),
                    case_references=case_refs
                ))
            return output_args

        strengths = convert_to_arguments(structured_analysis.get("strengths"))
        weaknesses = convert_to_arguments(structured_analysis.get("weaknesses"))
        
        return AnalysisResponse(
            caseId=case_id,
            strengths=strengths,
            weaknesses=weaknesses
        )
        
    except Exception as e:
        print(f"Error in add_case: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 