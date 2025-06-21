from pydantic import BaseModel
from typing import List, Optional

class HealthResponse(BaseModel):
    status: str
    timestamp: str

class RelatedCase(BaseModel):
    caseIdentifier: str
    status: str
    matching: float

class Argument(BaseModel):
    argument: str
    relatedCases: List[RelatedCase]

class AnalysisResponse(BaseModel):
    arguments: List[Argument]

class AddCaseRequest(BaseModel):
    user_prompt: str 