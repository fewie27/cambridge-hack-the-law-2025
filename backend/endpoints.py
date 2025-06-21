from datetime import datetime
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

# Import generated models
from models import HealthResponse, Argument, RelatedCase, AnalysisResponse, AddCaseRequest

# Create router for API endpoints
api_router = APIRouter(prefix="/api/v1", tags=["API"])

# Mock data for demonstration
MOCK_CASES = [
    RelatedCase(
        caseIdentifier="CASE-2024-001",
        status="Closed",
        matching=85
    ),
    RelatedCase(
        caseIdentifier="CASE-2023-045",
        status="Active",
        matching=72
    ),
    RelatedCase(
        caseIdentifier="CASE-2023-089",
        status="Closed",
        matching=68
    )
]

MOCK_ARGUMENTS = [
    Argument(
        argument="Wrongful termination based on discrimination",
        relatedCases=[MOCK_CASES[0], MOCK_CASES[1]]
    ),
    Argument(
        argument="Breach of employment contract",
        relatedCases=[MOCK_CASES[2]]
    ),
    Argument(
        argument="Retaliation for whistleblowing",
        relatedCases=[MOCK_CASES[1]]
    )
]

@api_router.post("/add_case", response_model=AnalysisResponse)
async def add_case(request: AddCaseRequest):
    """Add a new case with user prompt analysis"""
    if not request.user_prompt or len(request.user_prompt.strip()) == 0:
        raise HTTPException(status_code=400, detail="User prompt cannot be empty")
    
    if len(request.user_prompt) > 1000:
        raise HTTPException(status_code=400, detail="User prompt too long (max 1000 characters)")
    
    # For demonstration, return mock data
    # In a real implementation, this would use NLP/AI to analyze the prompt
    # and find relevant legal arguments and cases
    
    return AnalysisResponse(arguments=MOCK_ARGUMENTS) 