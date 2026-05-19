import logging
from google import genai
from app.core.config import settings

logger = logging.getLogger(__name__)

class GeminiService:
    """
    Wrapper for Google GenAI SDK (Gemini 2.5 Flash/Pro).
    """
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        logger.info("GeminiService initialized.")

    async def analyze_crisis_image(self, image_bytes: bytes, prompt: str) -> str:
        # Placeholder for actual Gemini Vision call
        logger.info("Analyzing image via Gemini Vision.")
        return "High confidence of urban flooding detected in the image."
        
    async def reason_about_crisis(self, context: str) -> str:
        # Placeholder for text reasoning
        logger.info("Reasoning via Gemini 2.5 Flash.")
        return "Based on the multi-modal data, this is a Category 4 emergency."\n