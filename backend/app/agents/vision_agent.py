import asyncio
import logging
import json
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.image_analysis_service import ImageAnalysisService
from app.services.emergency_classifier import EmergencyClassifier
from app.services.severity_engine import SeverityEngine
from app.agents.vision_prompts import VISION_SYSTEM_PROMPT

logger = logging.getLogger(__name__)

class VisionAnalysisSchema(BaseModel):
    detected_event: str = Field(..., description="The main emergency event category detected, e.g., Urban Flooding, Road Accident, Severe Weather, None")
    confidence: float = Field(..., description="Confidence score from 0.0 to 1.0 representing AI classification assurance")
    severity: str = Field(..., description="Severity scaling: LOW, MEDIUM, HIGH, SEVERE")
    detected_objects: List[str] = Field(default_factory=list, description="Observed hazardous visual elements like flooded road, water, trapped car, debris")
    risk_level: str = Field(..., description="Immediate localized risk designation matching severity")
    recommended_actions: List[str] = Field(default_factory=list, description="Immediate safety recommendations for citizens and dispatchers")
    ai_summary: str = Field(..., description="Textual description of the crisis and impact factors")

class VisionAgentResult(BaseModel):
    status: str = Field(..., description="Status of the agent execution")
    confidence_score: float = Field(..., description="Confidence score from 0.0 to 1.0")
    data: VisionAnalysisSchema = Field(..., description="Structured vision analysis payload")
    error: Optional[str] = None

class VisionAgent:
    """
    Multimodal AI Swarm Agent analyzing physical image uploads for crisis detection.
    """
    def __init__(self, agent_id: str = "vision-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        
        self.validation_service = ImageAnalysisService()
        self.classifier = EmergencyClassifier()
        self.severity_calc = SeverityEngine()

        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized VisionAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _call_gemini_with_retry(self, prompt: str, image_bytes: bytes) -> VisionAnalysisSchema:
        """
        Queries multimodal Gemini 2.5 Flash with retry support.
        """
        image_part = types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg")

        for attempt in range(self.max_retries):
            try:
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=[prompt, image_part],
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=VisionAnalysisSchema,
                        temperature=0.1,
                    )
                )
                data = json.loads(response.text)
                return VisionAnalysisSchema(**data)
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt)

    async def execute(self, payload: Dict[str, Any]) -> VisionAgentResult:
        """
        Main routing gateway. Accepts image bytes and returns structural hazard profiles.
        """
        logger.info(f"VisionAgent processing payload...")
        image_bytes = payload.get("image_bytes")
        filename = payload.get("filename", "emergency.jpg")

        if not image_bytes:
            return VisionAgentResult(
                status="failed",
                confidence_score=0.0,
                error="No 'image_bytes' present in upload request payload.",
                data=self._get_fallback_mock_data()
            )

        # 1. Image Pre-validation
        valid, msg = self.validation_service.validate_image(image_bytes, filename)
        if not valid:
            return VisionAgentResult(
                status="failed",
                confidence_score=0.0,
                error=msg,
                data=self._get_fallback_mock_data()
            )

        if not self.client:
            # Simulated Sandbox mode
            mock_data = self._get_fallback_mock_data()
            return VisionAgentResult(
                status="success",
                confidence_score=0.92,
                data=mock_data
            )

        try:
            structured_vision = await self._call_gemini_with_retry(VISION_SYSTEM_PROMPT, image_bytes)
            return VisionAgentResult(
                status="success",
                confidence_score=structured_vision.confidence,
                data=structured_vision
            )
        except Exception as e:
            logger.critical(f"Vision Agent pipeline failed: {str(e)}", exc_info=True)
            return VisionAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e),
                data=self._get_fallback_mock_data()
            )

    def _get_fallback_mock_data(self) -> VisionAnalysisSchema:
        """
        Fallback simulation data for development sandbox.
        """
        return VisionAnalysisSchema(
            detected_event="Urban Flooding",
            confidence=0.92,
            severity="HIGH",
            detected_objects=["flood water", "trapped vehicles", "blocked road"],
            risk_level="HIGH",
            recommended_actions=["avoid area", "reroute traffic", "dispatch emergency team"],
            ai_summary="Heavy waterlogging observed across the Jinnah expressway with deep standing water and multiple trapped consumer vehicles. Travel strongly discouraged."
        )
