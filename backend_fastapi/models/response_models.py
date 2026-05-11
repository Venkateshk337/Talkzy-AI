from pydantic import BaseModel
from typing import Optional

class EnglishCorrectionRequest(BaseModel):
    text: str
    user_language: str = "kannada"
    english_level: str = "beginner"
    learning_goal: str = "daily_conversation"
    mode: str = "correction"

class EnglishCorrectionResponse(BaseModel):
    mode: str
    original_text: str
    language_detected: str
    corrected_sentence: str
    short_explanation: str
    motivation: str
    confidence: float
    tone: str = "friendly"
    assistant_reply: Optional[str] = None

class HealthResponse(BaseModel):
    status: str
    message: str
    services: dict

class ErrorResponse(BaseModel):
    error: str
    message: str
    details: Optional[dict] = None
