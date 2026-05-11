from fastapi import APIRouter, HTTPException, status
from typing import Optional
import logging

from models.response_models import (
    EnglishCorrectionRequest, 
    EnglishCorrectionResponse, 
    ErrorResponse,
    HealthResponse
)
from services.ai_service import AIService

logger = logging.getLogger(__name__)
router = APIRouter()

# Global AI service instance
ai_service: Optional[AIService] = None

def set_ai_service(service: AIService):
    """Set the global AI service instance"""
    global ai_service
    ai_service = service

@router.post("/api/correct", response_model=EnglishCorrectionResponse)
async def correct_english(request: EnglishCorrectionRequest):
    """
    Correct English text based on user input and settings
    """
    if not ai_service:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="AI service not available"
        )
    
    try:
        result = await ai_service.correct_english(
            text=request.text,
            user_language=request.user_language,
            english_level=request.english_level,
            learning_goal=request.learning_goal,
            mode=request.mode
        )
        
        if result:
            return result
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to process request with AI services"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in correct_english: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )

@router.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint
    """
    try:
        service_status = ai_service.get_service_status() if ai_service else {"error": "AI service not initialized"}
        
        return HealthResponse(
            status="healthy",
            message="English Learning API is running",
            services=service_status
        )
    except Exception as e:
        logger.error(f"Health check error: {str(e)}")
        return HealthResponse(
            status="unhealthy",
            message=f"Health check failed: {str(e)}",
            services={"error": str(e)}
        )

@router.get("/status")
async def get_status():
    """
    Get API and service status
    """
    try:
        if ai_service:
            return {
                "status": "running",
                "services": ai_service.get_service_status(),
                "endpoints": {
                    "correct": "/api/correct",
                    "health": "/health",
                    "status": "/status"
                }
            }
        else:
            return {
                "status": "running",
                "services": {"error": "AI service not initialized"},
                "endpoints": {
                    "health": "/health",
                    "status": "/status"
                }
            }
    except Exception as e:
        logger.error(f"Status check error: {str(e)}")
        return {
            "status": "error",
            "error": str(e)
        }
