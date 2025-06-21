from datetime import datetime, date
from typing import List, Optional
from pydantic import BaseModel

# Auto-generated models from OpenAPI spec

class CaseReference(BaseModel):
    caseIdentifier: str
    title: str
    Date: Optional[date]
    matchingDegree: float
    sourcefile_raw_md: str
    # Additional case details
    caseNumber: Optional[str] = None
    industries: Optional[List[str]] = None
    status: Optional[str] = None
    partyNationalities: Optional[List[str]] = None
    institution: Optional[str] = None
    rulesOfArbitration: Optional[List[str]] = None
    applicableTreaties: Optional[List[str]] = None
    decisions: Optional[List[dict]] = None

class Argument(BaseModel):
    argument: str
    case_references: List[CaseReference]

class AnalysisResponse(BaseModel):
    caseId: str
    strengths: List[Argument]
    weaknesses: List[Argument]

class AddCaseRequest(BaseModel):
    user_prompt: str
    claimant: Optional[str] = None
    respondent: Optional[str] = None
    case_year: Optional[int] = None

class HealthResponse(BaseModel):
    status: str
    timestamp: datetime
    version: str

class Error(BaseModel):
    error: str
    code: str

class GenDraftRequest(BaseModel):
    case_id: str

class GenDraftResponse(BaseModel):
    text: str

class GenerateDraftTextRequest(BaseModel):
    case_id: str

class GenerateDraftTextResponse(BaseModel):
    draft_text: str