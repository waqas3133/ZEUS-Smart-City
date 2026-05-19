import asyncio
import logging
import json
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.congestion_analyzer import CongestionAnalyzer
from app.services.routing_service import RoutingService
from app.services.simulation_engine import TrafficSimulationEngine

logger = logging.getLogger(__name__)

class TrafficIntelligenceSchema(BaseModel):
    traffic_status: str = Field(..., description="Overall traffic status, e.g., CONGESTED, BLOCKED, CLEAR")
    blocked_routes: List[str] = Field(default_factory=list, description="List of completely blocked or highly flooded streets")
    recommended_routes: List[str] = Field(default_factory=list, description="Suggested bypass streets and alternate routes")
    estimated_delay: str = Field(..., description="Expected travel time delay, e.g., '20 mins delay'")
    risk_level: str = Field(..., description="Overall danger or flood risk level: LOW, MODERATE, HIGH, CRITICAL")
    ai_recommendation: str = Field(..., description="Personalized recommendation text")
    simulation_impact: str = Field(..., description="Analytical projected impact on congestion index")

class TrafficAgentResult(BaseModel):
    status: str = Field(..., description="Status of the agent execution")
    confidence_score: float = Field(..., description="Confidence score from 0.0 to 1.0")
    data: TrafficIntelligenceSchema = Field(..., description="Structured traffic intelligence payload")
    error: Optional[str] = None

class TrafficAgent:
    """
    Production-grade AI Agent for Traffic Intelligence.
    Integrates with Google Antigravity & Gemini 2.5.
    """
    def __init__(self, agent_id: str = "traffic-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        self.congestion_analyzer = CongestionAnalyzer()
        self.routing_service = RoutingService()
        self.sim_engine = TrafficSimulationEngine()

        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized TrafficAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _call_gemini_with_retry(self, prompt: str) -> TrafficIntelligenceSchema:
        """
        Executes structured content generation with retries.
        """
        for attempt in range(self.max_retries):
            try:
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=TrafficIntelligenceSchema,
                        temperature=0.1,
                    )
                )
                data = json.loads(response.text)
                return TrafficIntelligenceSchema(**data)
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt)

    async def execute(self, payload: Dict[str, Any]) -> TrafficAgentResult:
        """
        Main orchestration hook.
        """
        logger.info(f"TrafficAgent processing payload...")
        origin = payload.get("origin", "Karachi")
        destination = payload.get("destination", "Karachi Airport")
        blocked_streets = payload.get("blocked_streets", ["Shahrah Faisal"])

        # 1. Retrieve alternate routes bypassing flooded sectors
        route_info = await self.routing_service.calculate_alternative_route(origin, destination, blocked_streets)

        # 2. Run active dispatch simulation
        sim_data = await self.sim_engine.run_dispatch_simulation("Urban Flooding", origin, destination)

        if not self.client:
            # Mock mode
            return TrafficAgentResult(
                status="success",
                confidence_score=0.95,
                data=TrafficIntelligenceSchema(
                    traffic_status="BLOCKED",
                    blocked_routes=blocked_streets,
                    recommended_routes=["Korangi Road", "Expressway Bypass"],
                    estimated_delay="25 mins delay",
                    risk_level="HIGH",
                    ai_recommendation=f"Mock AI: Avoid flooded areas around {blocked_streets[0]}. Route traffic via Korangi Road instead.",
                    simulation_impact=f"Congestion index optimized from 0.85 to 0.35 ({sim_data['optimizations']['congestion_reduction_pct']}% reduction)."
                )
            )

        # 3. Construct prompt for Gemini to synthesize insights
        prompt = f"""
        You are the ZEUS Smart City Traffic Intelligence Agent.
        Analyze the following live route alternate data and simulation metrics:
        
        Origin: {origin}
        Destination: {destination}
        Blocked Streets (due to Flooding/Incidents): {json.dumps(blocked_streets)}
        
        Calculated Alternate Route Details:
        {json.dumps(route_info, indent=2)}
        
        Rerouting Dispatch Simulation Results:
        {json.dumps(sim_data, indent=2)}
        
        Synthesize these details into our smart traffic intelligence model, generating the status, recommendations, delay analysis, and projected simulation impact.
        """

        try:
            structured_data = await self._call_gemini_with_retry(prompt)
            return TrafficAgentResult(
                status="success",
                confidence_score=0.98,
                data=structured_data
            )
        except Exception as e:
            logger.critical(f"Traffic Agent pipeline failed: {str(e)}", exc_info=True)
            return TrafficAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e),
                data=TrafficIntelligenceSchema(
                    traffic_status="CONGESTED",
                    blocked_routes=blocked_streets,
                    recommended_routes=["Safe Alternative"],
                    estimated_delay="Unknown delay",
                    risk_level="HIGH",
                    ai_recommendation=f"Failed to fetch AI insights. Bypass {blocked_streets}.",
                    simulation_impact="Error during simulation impact assessment."
                )
            )
