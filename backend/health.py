from datetime import datetime
from fastapi import APIRouter
from models import HealthResponse

# Create router for health endpoints
health_router = APIRouter(tags=["Health"])

@health_router.get("/health", response_model=HealthResponse)
async def get_health():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now(),
        version="1.0.0"
    ) 