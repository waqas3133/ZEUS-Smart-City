import asyncio
import logging
import json
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.priority_engine import PriorityEngine

logger = logging.getLogger(__name__)

class NotificationAlertSchema(BaseModel):
    alert_type: str = Field(..., description="Alert category: Rain Alert, Flood Alert, Storm Alert, Traffic Alert, Emergency Warning")
    severity: str = Field(..., description="Estimated severity: LOW, MEDIUM, HIGH, SEVERE")
    priority: str = Field(..., description="Computed notification priority: CRITICAL, HIGH, NORMAL")
    target_area: str = Field(..., description="Exact city or localized region targeted")
    notification_title: str = Field(..., description="Impactful push notification headline")
    notification_body: str = Field(..., description="Actionable safety push notification details")
    recommended_actions: List[str] = Field(default_factory=list, description="Immediate safety recommendations for citizens")
    ai_reasoning: str = Field(..., description="Swarm rationale explaining why this alert is generated and throttled factors")

class NotificationAgentResult(BaseModel):
    status: str = Field(..., description="Execution status")
    confidence_score: float = Field(..., description="Confidence index")
    data: NotificationAlertSchema = Field(..., description="Structured notification content")
    error: Optional[str] = None

class NotificationAgent:
    """
    Multimodal AI Swarm Agent specializing in contextual alert compilation and prioritization.
    """
    def __init__(self, agent_id: str = "notification-swarm-1"):
        self.agent_id = agent_id
        self.priority_engine = PriorityEngine()

        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized NotificationAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def execute(self, payload: Dict[str, Any]) -> NotificationAgentResult:
        """
        Main orchestration gateway. Resolves inputs and spits out structured notification schemas.
        """
        logger.info(f"NotificationAgent evaluating context...")
        
        event_source = payload.get("source", "Weather System")
        raw_description = payload.get("description", "Heavy precipitation and thunder observed.")
        city = payload.get("city", "Karachi")
        
        # 1. Smart alert throttling and duplicate suppression
        alert_type = "Storm Alert" if "storm" in raw_description.lower() else "Rain Alert"
        if self.priority_engine.should_throttle(alert_type, city):
            return NotificationAgentResult(
                status="throttled",
                confidence_score=0.98,
                data=self._get_fallback_alert(city, alert_type, "duplicate suppressed")
            )

        if not self.client:
            mock_data = self._get_fallback_alert(city, alert_type, "sandbox mock data")
            return NotificationAgentResult(
                status="success",
                confidence_score=0.90,
                data=mock_data
            )

        system_instruction = """
        You are the ZEUS Smart City Real-time Notification intelligence agent.
        Your task is to take emergency context (weather reports, traffic blocks) and generate:
        1. A strict push notification alert profile.
        2. High-impact alerts titles and warning details.
        3. Localized emergency actions.
        Ensure you match the required response schema exactly.
        """

        prompt = f"""
        Event Source: {event_source}
        City/Area: {city}
        Context Details: {raw_description}
        """

        try:
            response = await asyncio.to_thread(
                self.client.models.generate_content,
                model='gemini-2.5-flash',
                contents=[prompt],
                config=types.GenerateContentConfig(
                    system_instruction=system_instruction,
                    response_mime_type="application/json",
                    response_schema=NotificationAlertSchema,
                    temperature=0.1,
                )
            )
            data = json.loads(response.text)
            
            # Recalculate priority via PriorityEngine rules
            structured_alert = NotificationAlertSchema(**data)
            calced_priority = self.priority_engine.calculate_priority(
                structured_alert.severity,
                structured_alert.priority
            )
            data["priority"] = calced_priority
            
            return NotificationAgentResult(
                status="success",
                confidence_score=0.95,
                data=NotificationAlertSchema(**data)
            )
        except Exception as e:
            logger.critical(f"Notification Swarm failed: {e}", exc_info=True)
            return NotificationAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e),
                data=self._get_fallback_alert(city, alert_type, f"critical error: {str(e)}")
            )

    def _get_fallback_alert(self, city: str, alert_type: str, reason: str) -> NotificationAlertSchema:
        """
        Fallback simulation data for development sandbox.
        """
        return NotificationAlertSchema(
            alert_type=alert_type,
            severity="HIGH",
            priority="HIGH",
            target_area=city,
            notification_title=f"⚠️ {alert_type}: Extreme Weather Warning in {city}",
            notification_body="Heavy rain and lightning observed over major arterial streets. Seek high ground and limit unnecessary travel.",
            recommended_actions=["Limit driving", "Avoid basement parking areas", "Check live map rerouting"],
            ai_reasoning=f"Automatic safety warning fallback triggered due to: {reason}."
        )
