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
        # Generate a case ID based on timestamp and hash of prompt
        import hashlib
        import uuid
        case_id = f"CASE-{uuid.uuid4().hex[:8].upper()}"
        
        # For now, return sample data until embedding service is fully implemented
        # In production, this would use: embedding_service.search_similar_cases(request.user_prompt, top_k=10)
        
        # Sample strengths
        strengths = [
            Argument(
                argument="Strong precedent for employment discrimination claims",
                case_references=[
                    CaseReference(
                        caseIdentifier="CASE-2023-001",
                        title="Smith v. ABC Corporation",
                        Date=date(2023, 3, 15),
                        matchingDegree=0.92,
                        fileReference="employment_discrimination_2023_001.pdf"
                    ),
                    CaseReference(
                        caseIdentifier="CASE-2022-045",
                        title="Johnson v. XYZ Industries",
                        Date=date(2022, 11, 8),
                        matchingDegree=0.87,
                        fileReference="wrongful_termination_2022_045.pdf"
                    )
                ]
            ),
            Argument(
                argument="Clear violation of employment contract terms",
                case_references=[
                    CaseReference(
                        caseIdentifier="CASE-2023-012",
                        title="Brown v. Tech Solutions Ltd",
                        Date=date(2023, 1, 22),
                        matchingDegree=0.85,
                        fileReference="contract_violation_2023_012.pdf"
                    )
                ]
            )
        ]
        
        # Sample weaknesses
        weaknesses = [
            Argument(
                argument="At-will employment may limit claims",
                case_references=[
                    CaseReference(
                        caseIdentifier="CASE-2023-007",
                        title="Davis v. Global Corp",
                        Date=date(2023, 2, 10),
                        matchingDegree=0.78,
                        fileReference="at_will_employment_2023_007.pdf"
                    )
                ]
            ),
            Argument(
                argument="Insufficient documentation of discriminatory behavior",
                case_references=[
                    CaseReference(
                        caseIdentifier="CASE-2022-089",
                        title="Wilson v. Manufacturing Inc",
                        Date=None,  # Some cases might not have dates
                        matchingDegree=0.72,
                        fileReference="documentation_issues_2022_089.pdf"
                    )
                ]
            )
        ]
        
        return AnalysisResponse(
            caseId=case_id,
            strengths=strengths,
            weaknesses=weaknesses
        )
        
    except Exception as e:
        print(f"Error in add_case: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 