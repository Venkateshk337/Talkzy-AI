import logging
from typing import Optional
from fastapi import APIRouter, UploadFile, File, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from services.whisper_service import get_whisper_service
from services.gemini_service import get_gemini_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/voice", tags=["voice"])

class TranscriptionResponse(BaseModel):
    transcript: str
    corrected_text: Optional[str] = None
    error: Optional[str] = None

@router.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe_audio(audio: UploadFile = File(...)):
    """
    Transcribe uploaded audio file using Whisper and optionally correct with Gemini.
    
    Args:
        audio: Audio file (wav, webm, mp3, etc.)
        
    Returns:
        Transcribed text and optional corrected version
    """
    try:
        # Validate file
        if not audio.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No audio file provided"
            )
        
        # Check file size (limit to 25MB)
        file_size = 0
        content = await audio.read()
        file_size = len(content)
        
        if file_size > 25 * 1024 * 1024:  # 25MB limit
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail="Audio file too large. Maximum size is 25MB."
            )
        
        logger.info(f"Processing audio file: {audio.filename} ({file_size} bytes)")
        
        # Get services
        whisper_service = get_whisper_service()
        gemini_service = get_gemini_service()
        
        # Check if Whisper model is loaded
        if not whisper_service.is_model_loaded():
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Voice transcription service is initializing. Please try again."
            )
        
        # Save uploaded file temporarily
        temp_file_path = whisper_service.save_uploaded_file(content, audio.filename)
        if not temp_file_path:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to process audio file"
            )
        
        try:
            # Transcribe audio
            transcript = whisper_service.transcribe_audio_async(temp_file_path)
            
            if not transcript:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Could not transcribe audio. Please ensure the audio contains clear speech."
                )
            
            logger.info(f"Transcription successful: {transcript[:100]}...")
            
            # Apply Gemini correction for English learning
            corrected_text = None
            try:
                corrected_text = await gemini_service.correct_english(transcript)
                logger.info("Gemini correction applied successfully")
            except Exception as e:
                logger.warning(f"Gemini correction failed, returning raw transcript: {e}")
                # Continue with raw transcript if correction fails
            
            return TranscriptionResponse(
                transcript=transcript,
                corrected_text=corrected_text
            )
            
        finally:
            # Always clean up temporary file
            whisper_service.cleanup_temp_file(temp_file_path)
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Audio transcription failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Voice transcription failed. Please try again."
        )

@router.get("/status")
async def get_voice_service_status():
    """
    Get status of voice processing services.
    
    Returns:
        Service status information
    """
    try:
        whisper_service = get_whisper_service()
        gemini_service = get_gemini_service()
        
        return {
            "whisper": whisper_service.get_model_info(),
            "gemini": {
                "available": gemini_service is not None,
                "model": "gemini-pro" if gemini_service else None
            },
            "status": "healthy" if whisper_service.is_model_loaded() else "initializing"
        }
    except Exception as e:
        logger.error(f"Status check failed: {e}")
        return {
            "whisper": {"loaded": False, "error": str(e)},
            "gemini": {"available": False, "error": str(e)},
            "status": "error"
        }

@router.post("/transcribe-simple")
async def transcribe_audio_simple(audio: UploadFile = File(...)):
    """
    Simple transcription without Gemini correction.
    
    Args:
        audio: Audio file
        
    Returns:
        Just the transcribed text
    """
    try:
        # Validate file
        if not audio.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No audio file provided"
            )
        
        # Read file content
        content = await audio.read()
        
        # Check file size
        if len(content) > 25 * 1024 * 1024:  # 25MB limit
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail="Audio file too large. Maximum size is 25MB."
            )
        
        logger.info(f"Simple transcription for: {audio.filename}")
        
        # Get Whisper service
        whisper_service = get_whisper_service()
        
        if not whisper_service.is_model_loaded():
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Voice transcription service is initializing. Please try again."
            )
        
        # Save and transcribe
        temp_file_path = whisper_service.save_uploaded_file(content, audio.filename)
        if not temp_file_path:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to process audio file"
            )
        
        try:
            transcript = whisper_service.transcribe_audio_async(temp_file_path)
            
            if not transcript:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Could not transcribe audio"
                )
            
            return {"transcript": transcript}
            
        finally:
            whisper_service.cleanup_temp_file(temp_file_path)
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Simple transcription failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Voice transcription failed. Please try again."
        )
