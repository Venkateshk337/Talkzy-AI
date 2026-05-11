import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from services.ai_service import AIService
from services.whisper_service import get_whisper_service
from routes.english_routes import router, set_ai_service
from routes.voice_routes import router as voice_router

# Load environment variables
load_dotenv()
from services.whisper_service import get_whisper_service


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting English Learning API...")
    
    # Initialize AI service
    try:
        gemini_api_key = os.getenv("GEMINI_API_KEY")
        openai_api_key = os.getenv("OPENAI_API_KEY")
        primary_service = os.getenv("PRIMARY_AI_SERVICE", "gemini")
        fallback_service = os.getenv("FALLBACK_AI_SERVICE", "openai")
        
        if not gemini_api_key and not openai_api_key:
            logger.error("No API keys found in environment variables")
            raise HTTPException(
                status_code=500,
                detail="No AI service API keys configured"
            )
        
        ai_service_instance = AIService(
            gemini_api_key=gemini_api_key,
            openai_api_key=openai_api_key,
            primary_service=primary_service,
            fallback_service=fallback_service
        )
        
        set_ai_service(ai_service_instance)
        logger.info(f"AI Service initialized with primary: {primary_service}, fallback: {fallback_service}")
        
    except Exception as e:
        logger.error(f"Failed to initialize AI service: {str(e)}")
        raise
    
    # Initialize Whisper service
    try:
        whisper_service = get_whisper_service()
        logger.info("Whisper service initialized for voice transcription")
    except Exception as e:
        logger.warning(f"Whisper service initialization failed: {e}")
        # Continue without voice service
    
    yield
    
    # Shutdown
    logger.info("Shutting down English Learning API...")

# Create FastAPI app
app = FastAPI(
    title="English Learning AI API",
    description="AI-powered English learning assistant for Kannada speakers",
    version="1.0.0",
    lifespan=lifespan
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://my-second-project-78537.web.app",
        "http://localhost:3000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Add CORS middleware
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # In production, specify your frontend domain
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# Include routes
app.include_router(router)
app.include_router(voice_router)

@app.get("/")
async def root():
    """
    Root endpoint
    """
    return {
        "message": "English Learning AI API",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "status": "/status", 
            "correct": "/api/correct",
            "voice_transcribe": "/voice/transcribe",
            "voice_status": "/voice/status"
        }
    }

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "localhost")
    port = int(os.getenv("PORT", "8000"))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info" if not debug else "debug"
    )
