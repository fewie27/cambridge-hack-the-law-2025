from datetime import datetime, date
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import re
import html
import unicodedata

# Import generated models
from models import Argument, CaseReference, AnalysisResponse, AddCaseRequest, GenDraftRequest, GenDraftResponse

# Import embedding service
from services.embedding_service import EmbeddingService

# Create router for API endpoints
api_router = APIRouter(prefix="/api/v1", tags=["API"])

# Initialize embedding service
embedding_service = EmbeddingService()

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
                    case_identifier = sanitize_text(meta.get("Identifier") or meta.get("case_id") or meta.get("source_file") or "N/A")
                    title = sanitize_text(meta.get("Title") or meta.get("title") or meta.get("source_file") or "Unknown Title")
                    decision_date = meta.get("DecisionDate") or meta.get("date")
                    sourcefile_raw_md = sanitize_text(meta.get("source_file") or meta.get("file_path") or "N/A")
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
                        sourcefile_raw_md=sourcefile_raw_md
                    ))
                output_args.append(Argument(
                    argument=sanitize_text(item.get("argument", "No argument provided.")),
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

@api_router.get("/gen_draft", response_model=GenDraftResponse)
async def gen_draft(case_id: str):
    """Generate a legal draft for a case"""

    from datetime import date

    html_template = r"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <title>Claim Submissions</title>
    <style>
        body {{
            font-family: "Times New Roman", serif;
            margin: 40px;
            line-height: 1.6;
        }}
        .center {{
            text-align: center;
        }}
        .underline {{
            text-decoration: underline;
        }}
        .italic {{
            font-style: italic;
        }}
        .bold {{
            font-weight: bold;
        }}
        .section-title {{
            margin-top: 2em;
        }}
        blockquote {{
            margin-left: 2em;
            font-style: italic;
        }}
    </style>
    </head>
    <body>

    <p class="center bold underline">IN THE MATTER OF THE ARBITRATION ACT 1996</p>
    <p class="center bold underline">AND IN THE MATTER OF AN ARBITRATION</p>

    <p class="center bold">BETWEEN:</p>

    <p class="center bold">{claimants}<br><span class="italic">Claimants</span></p>

    <p class="center bold">-and-</p>

    <p class="center bold">{respondents}<br><span class="italic">Respondents</span></p>

    <p class="center bold italic">{title}</p>

    <hr>

    <p class="center bold">CLAIM SUBMISSIONS</p>

    <hr>

    <h3 class="section-title">The Claimants</h3>

    <p>{intro_statement}</p>

    <h3 class="section-title">The contractual background</h3>

    {body}

    <hr style="margin-top: 3em;">

    <p><strong>Date:</strong> {date}</p>
    <p><strong>Signature:</strong> _____________________________</p>

    </body>
    </html>
    """

    try:
        if not case_id:
            raise HTTPException(status_code=400, detail="case_id is required")
            
        # TODO: Implement actual draft generation logic
        # For now, return a dummy response with the case_id included
        sanitized_case_id = sanitize_text(case_id)
        return GenDraftResponse(
            text=sanitize_text(html_template.format(
                claimants=f"Claimants (Case: {sanitized_case_id})",
                respondents="Respondents",
                title="Title",
                intro_statement="Intro Statement",
                body="Body",
                date=date.today().strftime("%d %B %Y")
            ))
        )
    except Exception as e:
        print(f"Error in gen_draft: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}") 