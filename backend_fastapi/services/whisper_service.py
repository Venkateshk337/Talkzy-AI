import os
import uuid
import tempfile
import logging
from typing import Optional
from concurrent.futures import ThreadPoolExecutor

from faster_whisper import WhisperModel

logger = logging.getLogger(__name__)


class WhisperService:
    def __init__(self, model_size: str = "tiny"):
        """
        Whisper transcription service
        optimized for lightweight CPU usage.
        """

        self.model_size = model_size
        self.model = None

        # Thread pool for background transcription
        self.executor = ThreadPoolExecutor(max_workers=2)

        self._load_model()

    def _load_model(self):
        """
        Load Whisper model once during startup.
        """

        try:
            logger.info(
                f"Loading Whisper model: {self.model_size}"
            )

            self.model = WhisperModel(
                self.model_size,
                device="cpu",
                compute_type="int8",
            )

            logger.info(
                f"Whisper model {self.model_size} loaded successfully"
            )

        except Exception:
            logger.exception(
                "Failed to load Whisper model"
            )

            self.model = None

    def transcribe_audio(
        self,
        audio_file_path: str,
    ) -> Optional[str]:
        """
        Transcribe audio file using Faster-Whisper.
        """

        if not self.model:
            logger.error("Whisper model not loaded")
            return None

        if not os.path.exists(audio_file_path):
            logger.error(
                f"Audio file not found: {audio_file_path}"
            )
            return None

        try:
            logger.info(
                f"Transcribing audio file: {audio_file_path}"
            )

            # Auto-detect language
            segments, info = self.model.transcribe(
                audio_file_path,
                beam_size=1,
            )

            transcript = " ".join(
                segment.text for segment in segments
            ).strip()

            logger.info(
                f"Detected language: {info.language}"
            )

            logger.info(
                f"Transcription completed: {transcript[:100]}"
            )

            return transcript if transcript else None

        except Exception:
            logger.exception(
                "Transcription failed"
            )

            return None

    def transcribe_audio_async(
        self,
        audio_file_path: str,
    ) -> Optional[str]:
        """
        Run transcription in background thread.
        """

        try:
            future = self.executor.submit(
                self.transcribe_audio,
                audio_file_path,
            )

            return future.result(timeout=60)

        except Exception:
            logger.exception(
                "Async transcription failed"
            )

            return None

    def save_uploaded_file(
        self,
        audio_data: bytes,
        filename: str,
    ) -> Optional[str]:
        """
        Save uploaded audio safely.
        """

        try:
            # File size limit: 20MB
            max_size = 20 * 1024 * 1024

            if len(audio_data) > max_size:
                logger.error(
                    "Audio file too large"
                )

                return None

            # Unique filename
            unique_filename = (
                f"{uuid.uuid4()}_{filename}"
            )

            temp_dir = tempfile.gettempdir()

            temp_path = os.path.join(
                temp_dir,
                unique_filename,
            )

            with open(temp_path, "wb") as f:
                f.write(audio_data)

            logger.info(
                f"Audio file saved: {temp_path}"
            )

            return temp_path

        except Exception:
            logger.exception(
                "Failed to save audio file"
            )

            return None

    def cleanup_temp_file(
        self,
        file_path: str,
    ):
        """
        Delete temporary audio file.
        """

        try:
            if (
                file_path
                and os.path.exists(file_path)
            ):
                os.remove(file_path)

                logger.info(
                    f"Deleted temp file: {file_path}"
                )

        except Exception:
            logger.warning(
                f"Failed to delete temp file: {file_path}"
            )

    def is_model_loaded(self) -> bool:
        """
        Check if model loaded successfully.
        """

        return self.model is not None

    def get_model_info(self) -> dict:
        """
        Get model information.
        """

        return {
            "model_size": self.model_size,
            "loaded": self.is_model_loaded(),
            "device": "cpu",
            "compute_type": "int8",
        }

    def shutdown(self):
        """
        Shutdown thread pool cleanly.
        """

        try:
            self.executor.shutdown(wait=False)

        except Exception:
            logger.exception(
                "Failed to shutdown executor"
            )

    def __del__(self):
        self.shutdown()


# Singleton instance
_whisper_service = None


def get_whisper_service() -> WhisperService:
    """
    Get singleton Whisper service.
    """

    global _whisper_service

    if _whisper_service is None:
        _whisper_service = WhisperService(
            model_size="tiny"
        )

    return _whisper_service