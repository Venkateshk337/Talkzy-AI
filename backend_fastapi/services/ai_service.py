import logging
from typing import Optional
from models.response_models import EnglishCorrectionResponse
from services.gemini_service import GeminiService
from services.openai_service import OpenAIService

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self, 
                 gemini_api_key: str, 
                 openai_api_key: str,
                 primary_service: str = "gemini",
                 fallback_service: str = "openai"):
        self.gemini_service = GeminiService(gemini_api_key) if gemini_api_key else None
        self.openai_service = OpenAIService(openai_api_key) if openai_api_key else None
        self.primary_service = primary_service
        self.fallback_service = fallback_service
        
    async def correct_english(self, 
                           text: str, 
                           user_language: str = "kannada",
                           english_level: str = "beginner",
                           learning_goal: str = "daily_conversation",
                           mode: str = "correction") -> Optional[EnglishCorrectionResponse]:
        """
        Correct English using primary AI service with fallback
        """
        logger.info(f"Processing request: text='{text}', language={user_language}, level={english_level}, goal={learning_goal}, mode={mode}")
        
        # Try primary service first
        result = await self._try_service(
            self.primary_service, 
            text, 
            user_language, 
            english_level, 
            learning_goal, 
            mode
        )
        
        if result:
            logger.info(f"Success with primary service: {self.primary_service}")
            return result
            
        # Try fallback service
        if self.primary_service != self.fallback_service:
            logger.warning(f"Primary service {self.primary_service} failed, trying fallback: {self.fallback_service}")
            result = await self._try_service(
                self.fallback_service, 
                text, 
                user_language, 
                english_level, 
                learning_goal, 
                mode
            )
            
            if result:
                logger.info(f"Success with fallback service: {self.fallback_service}")
                return result
        
        logger.error("All AI services failed, using fallback response")
        return self._get_fallback_response(text, user_language, english_level, learning_goal, mode)
    
    async def _try_service(self, 
                         service_name: str, 
                         text: str, 
                         user_language: str, 
                         english_level: str, 
                         learning_goal: str, 
                         mode: str) -> Optional[EnglishCorrectionResponse]:
        """
        Try a specific AI service
        """
        logger.info(f"Trying {service_name} service...")
        try:
            if service_name == "gemini" and self.gemini_service:
                logger.info("Using Gemini service")
                return await self.gemini_service.correct_english(
                    text, user_language, english_level, learning_goal, mode
                )
            elif service_name == "openai" and self.openai_service:
                logger.info("Using OpenAI service")
                return await self.openai_service.correct_english(
                    text, user_language, english_level, learning_goal, mode
                )
            else:
                logger.error(f"Unknown service: {service_name} or service not initialized")
                return None
                
        except Exception as e:
            logger.error(f"Error in {service_name} service: {str(e)}")
            logger.error(f"Exception type: {type(e).__name__}")
            logger.error(f"Exception details: {repr(e)}")
            return None
    
    def _get_fallback_response(self, text: str, user_language: str, english_level: str, learning_goal: str, mode: str) -> EnglishCorrectionResponse:
        """
        Generate a fallback response when AI services are unavailable
        """
        logger.info(f"Generating fallback response for: '{text}'")
        
        # Simple fallback responses based on mode
        if mode == "conversation":
            fallback_text = f"That's interesting! Tell me more about '{text}'. I'm here to help you practice English conversation."
        else:
            # Correction mode
            fallback_text = f"Your sentence '{text}' is noted. I'm currently experiencing technical difficulties with AI services, but I can help you practice English. Try typing another sentence!"
        
        return EnglishCorrectionResponse(
            mode=mode,
            original_text=text,
            language_detected=user_language,
            corrected_sentence=fallback_text,
            short_explanation="AI services are temporarily unavailable. This is a fallback response.",
            motivation="Keep practicing! Your English will improve with regular practice.",
            confidence=0.5,
            tone="friendly",
            assistant_reply=fallback_text if mode == "conversation" else None
        )
    
    def get_service_status(self) -> dict:
        """
        Get status of all AI services
        """
        return {
            "gemini": self.gemini_service is not None,
            "openai": self.openai_service is not None,
            "primary": self.primary_service,
            "fallback": self.fallback_service
        }
