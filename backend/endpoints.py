from datetime import datetime
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

# Import generated models
from models import HealthResponse, Argument, RelatedCase, AnalysisResponse, AddCaseRequest

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
        # Search for similar cases using the user prompt
        similar_cases = embedding_service.search_similar_cases(request.user_prompt, top_k=10)
        
        # Group cases by argument type
        argument_groups = {}
        
        for case in similar_cases:
            argument = case["metadata"]["argument"]
            if argument not in argument_groups:
                argument_groups[argument] = []
            
            # Create RelatedCase object
            related_case = RelatedCase(
                caseIdentifier=case["metadata"]["case_id"],
                status=case["metadata"]["status"],
                matching=case["matching"]
            )
            
            argument_groups[argument].append(related_case)
        
        # Create Argument objects from grouped cases
        arguments = []
        for argument_text, related_cases in argument_groups.items():
            argument_obj = Argument(
                argument=argument_text,
                relatedCases=related_cases
            )
            arguments.append(argument_obj)
        
        # If no similar cases found, return empty response
        if not arguments:
            return AnalysisResponse(arguments=[])
        
        return AnalysisResponse(arguments=arguments)
        
    except Exception as e:
        print(f"Error in add_case: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 