import asyncio
import logging
import json
from typing import Dict, Any, Optional
from google import genai
from google.genai import types

from app.core.config import settings
from .schemas import CrisisIntelligenceSchema
from .prompts import SYSTEM_PROMPT, build_crisis_prompt

logger = logging.getLogger(__name__)

class CrisisIntelligenceAgent:
    """
    Enterprise-grade AI Intelligence Agent for ZEUS Smart City.
    Processes multi-lingual emergency texts and returns structured JSON.
    """
    def __init__(self, agent_id: str = "crisis-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized CrisisIntelligenceAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _call_gemini_with_retry(self, prompt: str) -> CrisisIntelligenceSchema:
        """
        Executes the LLM call with an exponential backoff retry mechanism.
        """
        for attempt in range(self.max_retries):
            try:
                # Combine system instructions via standard prompt injection for Flash
                full_prompt = f"{SYSTEM_PROMPT}\\n\\n{prompt}"
                
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=full_prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=CrisisIntelligenceSchema,
                        temperature=0.1, # Low temperature for analytical consistency
                    )
                )
                
                # Parse and validate the response against the Pydantic schema
                data = json.loads(response.text)
                return CrisisIntelligenceSchema(**data)
                
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt) # Exponential backoff

    async def execute(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        Main Antigravity Orchestration Hook.
        Receives an event payload containing a 'report_text'.
        """
        logger.info(f"{self.agent_id} processing payload...")
        user_text = payload.get("report_text", "")
        
        if not user_text:
            return {
                "status": "failed",
                "error": "Missing 'report_text' in payload."
            }

        if not self.client:
            # Mock mode
            await asyncio.sleep(0.5)
            return {
                "status": "success",
                "data": CrisisIntelligenceSchema(
                    event_type="Mock Emergency",
                    severity="LOW",
                    confidence=0.99,
                    affected_area="Test Zone",
                    impact=["None"],
                    recommended_actions=["Stay calm"],
                    alert_priority="INFO",
                    reasoning="Running in mock mode due to missing API key."
                ).model_dump()
            }

        try:
            prompt = build_crisis_prompt(user_text)
            structured_result = await self._call_gemini_with_retry(prompt)
            
            return {
                "status": "success",
                "data": structured_result.model_dump()
            }
        except Exception as e:
            logger.critical(f"Crisis Intelligence Pipeline failed: {str(e)}", exc_info=True)
            return {
                "status": "failed",
                "error": str(e)
            }
