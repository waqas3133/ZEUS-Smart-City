import asyncio
import logging
import json
from typing import Dict, Any, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from app.core.config import settings

logger = logging.getLogger(__name__)

class CrisisDecisionSchema(BaseModel):
    severity_level: str = Field(description="Severity level: LOW, MODERATE, HIGH, CRITICAL")
    confidence_score: float = Field(description="Confidence score between 0.0 and 1.0")
    primary_crisis_type: str = Field(description="Type of crisis detected (e.g., Flood, Fire, Accident)")
    recommended_actions: list[str] = Field(description="List of immediate actions to take")
    requires_simulation: bool = Field(description="True if this event requires impact simulation")

class DecisionAgentResult(BaseModel):
    status: str = Field(..., description="Status of the agent execution")
    confidence_score: float = Field(..., description="Confidence score from 0.0 to 1.0")
    data: Dict[str, Any] = Field(default_factory=dict, description="Structured output payload")
    error: Optional[str] = None

class DecisionAgent:
    """
    Production-grade AI Agent for Master Crisis Decision.
    Integrates with Google Antigravity & Gemini 2.5.
    """
    def __init__(self, agent_id: str):
        self.agent_id = agent_id
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        else:
            self.client = None
            logger.warning("GEMINI_API_KEY not set. DecisionAgent will run in mock mode.")
        logger.info(f"Initialized DecisionAgent [{self.agent_id}]")

    async def _analyze_with_gemini(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Calls Gemini 2.5 Flash to make a master crisis decision based on multi-agent inputs.
        """
        if not self.client:
            await asyncio.sleep(0.5)
            return {
                "severity_level": "MODERATE",
                "confidence_score": 0.85,
                "primary_crisis_type": "Unknown",
                "recommended_actions": ["Dispatch local responder"],
                "requires_simulation": False
            }

        prompt = f"""
        You are the ZEUS Smart City Master Crisis Decision Agent.
        Analyze the following multi-agent intelligence payload and determine the crisis severity.
        
        Payload Context:
        {json.dumps(context, indent=2)}
        """
        
        # We use asyncio.to_thread since the genai sdk might be synchronous
        response = await asyncio.to_thread(
            self.client.models.generate_content,
            model='gemini-2.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=CrisisDecisionSchema,
                temperature=0.2,
            )
        )
        
        # Parse the structured JSON response
        decision_data = json.loads(response.text)
        return decision_data

    async def execute(self, payload: Dict[str, Any]) -> DecisionAgentResult:
        """
        Main orchestration hook.
        """
        logger.info(f"DecisionAgent processing payload...")
        try:
            analysis = await self._analyze_with_gemini(payload)
            score = analysis.get("confidence_score", 0.0)
            
            return DecisionAgentResult(
                status="success",
                confidence_score=score,
                data=analysis
            )
        except Exception as e:
            logger.error(f"DecisionAgent failed: {str(e)}", exc_info=True)
            return DecisionAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e)
            )
