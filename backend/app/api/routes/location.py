from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
import logging
from app.agents.location_intelligence.location_agent import LocationIntelligenceAgent

logger = logging.getLogger(__name__)
router = APIRouter()

class LocationPayload(BaseModel):
    lat: float = Field(..., description="Latitude coordinate")
    lng: float = Field(..., description="Longitude coordinate")

@router.post("/intelligence")
async def get_location_intelligence(payload: LocationPayload):
    """
    Ingests live GPS coordinates, runs reverse geocoding and proximity alert checks,
    and returns localized smart recommendations via the Location Intelligence Agent.
    """
    logger.info(f"Received coordinates check: {payload.lat}, {payload.lng}")
    agent = LocationIntelligenceAgent()
    
    result = await agent.execute({
        "lat": payload.lat,
        "lng": payload.lng
    })
    
    if result.get("status") == "success":
        return result
    else:
        raise HTTPException(
            status_code=500,
            detail=result.get("error", "Failed to compile location intelligence data.")
        )
