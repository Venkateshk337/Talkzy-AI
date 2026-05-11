import os
import json
import logging
import asyncio
from typing import Optional

import google.genai as genai
from google.genai.types import GenerateContentConfig

from models.response_models import EnglishCorrectionResponse

logger = logging.getLogger(__name__)


class GeminiService:
    def __init__(self, api_key: str):
        self.client = genai.Client(api_key=api_key)

        # Store model name only
        self.model_name = "gemini-2.5-flash"

    async def correct_english(
        self,
        text: str,
        user_language: str = "kannada",
        english_level: str = "beginner",
        learning_goal: str = "daily_conversation",
        mode: str = "correction",
    ) -> Optional[EnglishCorrectionResponse]:
        """
        Correct English using Gemini API
        """

        try:
            from prompts.system_prompt import get_system_prompt

            system_prompt = get_system_prompt(
                user_language,
                english_level,
                learning_goal,
                mode,
            )

            full_prompt = f"""
{system_prompt}

User input:
"{text}"

Return ONLY valid JSON.
"""

            generation_config = GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.7,
            )

            response = await asyncio.wait_for(
                asyncio.to_thread(
                    self.client.models.generate_content,
                    model=self.model_name,
                    contents=full_prompt,
                    config=generation_config,
                ),
                timeout=30.0,
            )

            if not response or not response.text:
                logger.error("Empty response from Gemini")
                return None

            response_text = response.text.strip()

            logger.info(
                f"Raw Gemini response: {response_text[:300]}"
            )

            try:
                response_data = json.loads(response_text)

            except json.JSONDecodeError as e:
                logger.warning(
                    f"Direct JSON parsing failed: {e}"
                )

                json_text = self._extract_json_from_response(
                    response_text
                )

                response_data = json.loads(json_text)

            # Safe confidence parsing
            try:
                confidence = float(
                    response_data.get("confidence", 0.8)
                )
            except Exception:
                confidence = 0.8

            return EnglishCorrectionResponse(
                mode=response_data.get("mode", mode),

                original_text=response_data.get(
                    "original_text",
                    text,
                ),

                language_detected=response_data.get(
                    "language_detected",
                    user_language,
                ),

                corrected_sentence=response_data.get(
                    "corrected_sentence",
                    text,
                ),

                short_explanation=response_data.get(
                    "short_explanation",
                    "",
                ),

                motivation=response_data.get(
                    "motivation",
                    "",
                ),

                confidence=confidence,

                tone=response_data.get(
                    "tone",
                    "friendly",
                ),

                assistant_reply=response_data.get(
                    "assistant_reply"
                ),
            )

        except asyncio.TimeoutError:
            logger.error("Gemini request timed out")
            return None

        except Exception:
            logger.exception(
                "Error in Gemini service"
            )
            return None

    def _extract_json_from_response(
        self,
        response_text: str,
    ) -> str:
        """
        Extract JSON safely from response text
        """

        try:
            start_idx = response_text.find("{")
            end_idx = response_text.rfind("}") + 1

            if start_idx != -1 and end_idx != -1:
                return response_text[start_idx:end_idx]

            return response_text

        except Exception:
            logger.exception(
                "Error extracting JSON"
            )

            return response_text


# Singleton instance
_gemini_service = None


def get_gemini_service() -> Optional[GeminiService]:
    """
    Get or create Gemini service singleton
    """

    global _gemini_service

    if _gemini_service is None:
        api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            logger.warning(
                "GEMINI_API_KEY not found"
            )
            return None

        _gemini_service = GeminiService(api_key)

    return _gemini_service