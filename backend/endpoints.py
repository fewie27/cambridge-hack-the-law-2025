from datetime import datetime, date
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import re
import html
import unicodedata

# Import generated models
from models import Argument, CaseReference, AnalysisResponse, AddCaseRequest, GenDraftRequest, GenDraftResponse

# Import services
from services.embedding_service import EmbeddingService
from services.document_service import DocumentService

# Import case storage
from database.case_storage import CaseStorage

# Create router for API endpoints
api_router = APIRouter(prefix="/api/v1", tags=["API"])

# Initialize services
embedding_service = EmbeddingService()
document_service = DocumentService()
case_storage = CaseStorage()

def sanitize_text(text: str) -> str:
    """
    Sanitizes text by removing or replacing problematic characters and sequences.
    
    Args:
        text: The input text to sanitize
        
    Returns:
        Cleaned text safe for JSON serialization and display
    """
    if not text or not isinstance(text, str):
        return ""
    
    # Attempt to fix common UTF-8 mis-encoding issues (mojibake)
    try:
        # This can fix strings like "Fenoscadiaâ\x80\x99s" back to "Fenoscadia's"
        text = text.encode('latin1').decode('utf-8')
    except (UnicodeEncodeError, UnicodeDecodeError):
        # This will fail if the string is already valid, which is fine.
        pass
    
    # Decode HTML entities
    text = html.unescape(text)
    
    # Normalize unicode characters
    text = unicodedata.normalize('NFKC', text)
    
    # Remove or replace problematic characters
    # Remove null bytes and other control characters except newlines and tabs
    text = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', text)
    
    # Replace multiple spaces with single space
    text = re.sub(r'\s+', ' ', text)
    
    # Remove leading/trailing whitespace
    text = text.strip()
    
    # Replace problematic unicode characters that might cause issues
    # Replace various quote types with standard quotes
    text = text.replace('"', '"').replace('"', '"')
    text = text.replace(''', "'").replace(''', "'")
    text = text.replace('–', '-').replace('—', '-')
    text = text.replace('…', '...')
    
    # Remove asterisks
    text = text.replace('*', '')
    
    # Remove .json extension
    text = text.replace('.json', '')
    
    # Remove any remaining non-printable characters
    text = ''.join(char for char in text if char.isprintable() or char in '\n\t')
    
    # Ensure the text is not too long (prevent memory issues)
    if len(text) > 10000:
        text = text[:10000] + "..."
    
    return text

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
                    full_case_data = meta.get("full_case_data", {})
                    
                    # Extract basic metadata
                    case_identifier = sanitize_text(meta.get("Identifier") or meta.get("case_id") or meta.get("source_file") or "N/A")
                    title = sanitize_text(meta.get("Title") or meta.get("title") or meta.get("source_file") or "Unknown Title")
                    decision_date = meta.get("DecisionDate") or meta.get("date")
                    sourcefile_raw_md = sanitize_text(meta.get("source_file") or meta.get("file_path") or "N/A")
                    
                    # Extract additional case details from full_case_data
                    case_number = sanitize_text(full_case_data.get("CaseNumber") or meta.get("CaseNumber") or "N/A")
                    industries = full_case_data.get("Industries") or []
                    status = sanitize_text(full_case_data.get("Status") or meta.get("Status") or "N/A")
                    party_nationalities = full_case_data.get("PartyNationalities") or []
                    institution = sanitize_text(full_case_data.get("Institution") or meta.get("Institution") or "N/A")
                    rules_of_arbitration = full_case_data.get("RulesOfArbitration") or []
                    applicable_treaties = full_case_data.get("ApplicableTreaties") or []
                    decisions = full_case_data.get("Decisions") or []
                    
                    # Sanitize lists
                    if isinstance(industries, list):
                        industries = [sanitize_text(str(item)) for item in industries if item]
                    if isinstance(party_nationalities, list):
                        party_nationalities = [sanitize_text(str(item)) for item in party_nationalities if item]
                    if isinstance(rules_of_arbitration, list):
                        rules_of_arbitration = [sanitize_text(str(item)) for item in rules_of_arbitration if item]
                    if isinstance(applicable_treaties, list):
                        applicable_treaties = [sanitize_text(str(item)) for item in applicable_treaties if item]
                    
                    parsed_date = None
                    if decision_date:
                        try:
                            # Sanitize the date string before parsing
                            clean_date = sanitize_text(decision_date)
                            parsed_date = date.fromisoformat(clean_date[:10])
                        except Exception:
                            parsed_date = None
                    
                    case_refs.append(CaseReference(
                        caseIdentifier=case_identifier,
                        title=title,
                        Date=parsed_date,
                        matchingDegree=1 - ref_data.get("distance", 1.0),
                        sourcefile_raw_md=sourcefile_raw_md,
                        # Additional case details
                        caseNumber=case_number,
                        industries=industries,
                        status=status,
                        partyNationalities=party_nationalities,
                        institution=institution,
                        rulesOfArbitration=rules_of_arbitration,
                        applicableTreaties=applicable_treaties,
                        decisions=decisions
                    ))
                output_args.append(Argument(
                    argument=sanitize_text(item.get("argument", "No argument provided.")),
                    case_references=case_refs
                ))
            return output_args

        strengths = convert_to_arguments(structured_analysis.get("strengths"))
        weaknesses = convert_to_arguments(structured_analysis.get("weaknesses"))
        
        response = AnalysisResponse(
            caseId=case_id,
            strengths=strengths,
            weaknesses=weaknesses
        )
        
        # Store the response
        case_storage.store_response(case_id, response.dict())
        
        return response
        
    except Exception as e:
        print(f"Error in add_case: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@api_router.get("/gen_draft", response_model=GenDraftResponse)
async def gen_draft(case_id: str):
    """Generate a legal draft for a case"""
    try:
        if not case_id:
            raise HTTPException(status_code=400, detail="case_id is required")
        
        # Try to retrieve the case response
        case_response = case_storage.get_response(case_id)
        if case_response is None:
            raise HTTPException(status_code=404, detail=f"Case with ID {case_id} not found")
        
        # Convert the stored response back to an AnalysisResponse model
        analysis = AnalysisResponse(**case_response)
        
        # Generate the document using our new service
        document_html = document_service.generate_draft(analysis, case_id)
        
        return GenDraftResponse(text=document_html)
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in gen_draft: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 