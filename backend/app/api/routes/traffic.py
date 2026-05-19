from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List
import logging
from app.agents.traffic_agent import TrafficAgent

logger = logging.getLogger(__name__)
router = APIRouter()

class TrafficSimulationPayload(BaseModel):
    origin: str = Field(..., description="Start location or coordinates")
    destination: str = Field(..., description="End location or coordinates")
    blocked_streets: List[str] = Field(default_factory=list, description="List of closed or flooded street names")

@router.post("/simulation")
async def run_traffic_simulation(payload: TrafficSimulationPayload):
    """
    Triggers an emergency rerouting simulation avoiding active crisis and flood zones.
    Returns AI comparative analysis of Before vs After optimizations.
    """
    logger.info(f"Incoming traffic simulation: {payload.origin} -> {payload.destination} avoiding {payload.blocked_streets}")
    agent = TrafficAgent()
    
    result = await agent.execute({
        "origin": payload.origin,
        "destination": payload.destination,
        "blocked_streets": payload.blocked_streets
    })
    
    if result.status == "success":
        return {
            "status": "success",
            "confidence": result.confidence_score,
            "data": result.data.model_dump()
        }
    else:
        raise HTTPException(
            status_code=500,
            detail=result.error or "Traffic simulation computation failed."
        )
