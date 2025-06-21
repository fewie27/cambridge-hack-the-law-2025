from datetime import datetime, date
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

# Import generated models
from models import Argument, CaseReference, AnalysisResponse, AddCaseRequest, GenDraftRequest, GenDraftResponse

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
        
        # Extract metadata from the user's prompt
        extracted_metadata = embedding_service.extract_metadata_from_prompt(request.user_prompt)

        # Use the explicit fields if provided, otherwise use the extracted metadata
        claimant = request.claimant or extracted_metadata.get("claimant")
        respondent = request.respondent or extracted_metadata.get("respondent")
        case_year = request.case_year or extracted_metadata.get("case_year")
        
        # Use the embedding service to find and analyze similar cases
        structured_analysis = embedding_service.search_similar_cases(
            user_prompt=request.user_prompt, 
            top_k=15,
            claimant=claimant,
            respondent=respondent,
            case_year=case_year
        )
        
        def convert_to_arguments(analysis_list):
            """Converts a list of dicts into a list of Argument Pydantic models."""
            if not analysis_list:
                return []
            
            output_args = []
            for item in analysis_list:
                case_refs = []
                for ref_data in item.get("case_references", []):
                    meta = ref_data.get("metadata", {})
                    case_identifier = meta.get("Identifier") or meta.get("case_id") or meta.get("source_file") or "N/A"
                    title = meta.get("Title") or meta.get("title") or meta.get("source_file") or "Unknown Title"
                    decision_date = meta.get("DecisionDate") or meta.get("date")
                    sourcefile_raw_md = meta.get("source_file") or meta.get("file_path") or "N/A"
                    parsed_date = None
                    if decision_date:
                        try:
                            parsed_date = date.fromisoformat(decision_date[:10])
                        except Exception:
                            parsed_date = None
                    case_refs.append(CaseReference(
                        caseIdentifier=case_identifier,
                        title=title,
                        Date=parsed_date,
                        matchingDegree=1 - ref_data.get("distance", 1.0),
                        sourcefile_raw_md=sourcefile_raw_md
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

@api_router.post("/gen_draft", response_model=GenDraftResponse)
async def gen_draft(request: GenDraftRequest):
    """Generate a legal draft for a case"""
    try:
        # TODO: Implement actual draft generation logic
        # For now, return a dummy response
        return GenDraftResponse(
            text=f"This is a dummy legal draft for case {request.case_id}. "
                 "The actual implementation will generate a proper legal document based on the case details and similar cases."
        )
    except Exception as e:
        print(f"Error in gen_draft: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 