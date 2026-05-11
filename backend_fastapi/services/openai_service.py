import openai
import json
import logging
from typing import Dict, Any, Optional
from models.response_models import EnglishCorrectionResponse

logger = logging.getLogger(__name__)

class OpenAIService:
    def __init__(self, api_key: str):
        self.client = openai.AsyncOpenAI(api_key=api_key)
        
    async def correct_english(self, 
                           text: str, 
                           user_language: str = "kannada",
                           english_level: str = "beginner",
                           learning_goal: str = "daily_conversation",
                           mode: str = "correction") -> Optional[EnglishCorrectionResponse]:
        """
        Correct English using OpenAI API
        """
        try:
            from prompts.system_prompt import get_system_prompt
            
            system_prompt = get_system_prompt(user_language, english_level, learning_goal, mode)
            
            response = await self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f'User input: "{text}"\n\nProvide response according to the specified JSON format.'}
                ],
                temperature=0.7,
                max_tokens=500
            )
            
            if response.choices and response.choices[0].message.content:
                content = response.choices[0].message.content
                json_text = self._extract_json_from_response(content)
                response_data = json.loads(json_text)
                
                return EnglishCorrectionResponse(
                    mode=response_data.get("mode", mode),
                    original_text=response_data.get("original_text", text),
                    language_detected=response_data.get("language_detected", user_language),
                    corrected_sentence=response_data.get("corrected_sentence", text),
                    short_explanation=response_data.get("short_explanation", ""),
                    motivation=response_data.get("motivation", ""),
                    confidence=float(response_data.get("confidence", 0.8)),
                    tone=response_data.get("tone", "friendly"),
                    assistant_reply=response_data.get("assistant_reply")
                )
            else:
                logger.error("Empty response from OpenAI")
                return None
                
        except Exception as e:
            logger.error(f"Error in OpenAI service: {str(e)}")
            return None
    
    def _extract_json_from_response(self, response_text: str) -> str:
        """
        Extract JSON from the response text
        """
        try:
            # Try to find JSON in the response
            start_idx = response_text.find('{')
            end_idx = response_text.rfind('}') + 1
            
            if start_idx != -1 and end_idx != -1:
                json_text = response_text[start_idx:end_idx]
                return json_text
            else:
                # If no JSON markers found, return the full text
                return response_text
                
        except Exception as e:
            logger.error(f"Error extracting JSON: {str(e)}")
            return response_text
