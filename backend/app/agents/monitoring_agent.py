import asyncio
import logging
import json
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

from app.core.config import settings

logger = logging.getLogger(__name__)

class CityHealthMatrixSchema(BaseModel):
    overall_status: str = Field(..., description="Overall health state: OPTIMAL, CAUTION, THREATENED, CRITICAL")
    risk_score: float = Field(..., description="Calculated aggregate risk percentage from 0.0 to 100.0")
    active_threats_count: int = Field(..., description="Estimated number of severe ongoing events")
    general_guidance: str = Field(..., description="Strategic recommendations for city administrators")
    monitored_sectors: List[str] = Field(default_factory=list, description="Sectors examined, e.g., Transportation, Weather, Power Grid")

class MonitoringAgentResult(BaseModel):
    status: str = Field(..., description="Execution status")
    confidence_score: float = Field(..., description="AI confidence rating")
    data: CityHealthMatrixSchema = Field(..., description="City health evaluation details")
    error: Optional[str] = None

class MonitoringAgent:
    """
    Multimodal AI Swarm Agent analyzing city-wide indicators to compile safety health matrices.
    """
    def __init__(self, agent_id: str = "monitoring-swarm-1"):
        self.agent_id = agent_id

        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized MonitoringAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def execute(self, payload: Dict[str, Any]) -> MonitoringAgentResult:
        """
        Main orchestration gateway. Resolves inputs and spits out structured notification schemas.
        """
        logger.info(f"MonitoringAgent analyzing city indicators...")
        
        active_incidents = payload.get("active_incidents", 2)
        weather_conditions = payload.get("weather_conditions", "Normal")
        traffic_congestion = payload.get("traffic_congestion", "Low")

        if not self.client:
            mock_data = self._get_fallback_health(active_incidents, weather_conditions)
            return MonitoringAgentResult(
                status="success",
                confidence_score=0.90,
                data=mock_data
            )

        system_instruction = """
        You are the ZEUS Smart City Command Center monitoring intelligence agent.
        Your task is to take active city parameters (active incidents count, weather forecasts, traffic congestion index)
        and compile:
        1. An overall city safety status indicator (OPTIMAL, CAUTION, THREATENED, CRITICAL).
        2. A numeric city risk rating (0.0 to 100.0).
        3. Strategic recommendations for city administrators to reroute resources.
        Ensure you match the required response schema exactly.
        """

        prompt = f"""
        Active Incidents Count: {active_incidents}
        Weather Forecast: {weather_conditions}
        Traffic Congestion: {traffic_congestion}
        """

        try:
            response = await asyncio.to_thread(
                self.client.models.generate_content,
                model='gemini-2.5-flash',
                contents=[prompt],
                config=types.GenerateContentConfig(
                    system_instruction=system_instruction,
                    response_mime_type="application/json",
                    response_schema=CityHealthMatrixSchema,
                    temperature=0.1,
                )
            )
            data = json.loads(response.text)
            return MonitoringAgentResult(
                status="success",
                confidence_score=0.94,
                data=CityHealthMatrixSchema(**data)
            )
        except Exception as e:
            logger.critical(f"Monitoring Swarm failed: {e}", exc_info=True)
            return MonitoringAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e),
                data=self._get_fallback_health(active_incidents, weather_conditions)
            )

    def _get_fallback_health(self, active_incidents: int, weather: str) -> CityHealthMatrixSchema:
        """
        Fallback simulation data for development sandbox.
        """
        status = "OPTIMAL"
        risk = 12.5
        
        if active_incidents >= 3 or "storm" in weather.lower():
            status = "CRITICAL"
            risk = 85.0
        elif active_incidents >= 1:
            status = "CAUTION"
            risk = 45.0

        return CityHealthMatrixSchema(
            overall_status=status,
            risk_score=risk,
            active_threats_count=active_incidents,
            general_guidance="Alert dispatch systems active. Monitor city expressways and underpasses closely for rain pooling.",
            monitored_sectors=["Transportation", "Weather Alerts", "Emergency Response Team"]
        )
