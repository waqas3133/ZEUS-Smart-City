from fastapi import APIRouter
from app.core.config import settings

router = APIRouter()

@router.get("/")
async def health_check():
    """
    Check if the API is running and returns basic service info.
    """
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION
    }
