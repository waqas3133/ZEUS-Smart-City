import asyncio
import logging
import json
from typing import Dict, Any
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.geocoding_service import GeocodingService
from app.services.nearby_alert_service import NearbyAlertService
from .schemas import LocationIntelligenceSchema

logger = logging.getLogger(__name__)

class LocationIntelligenceAgent:
    """
    Enterprise-grade AI Location Agent for ZEUS Smart City.
    Processes coordinates, fetches localized alerts, and generates AI safety context.
    """
    def __init__(self, agent_id: str = "loc-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        self.geocoding_service = GeocodingService()
        self.alert_service = NearbyAlertService()
        
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized LocationIntelligenceAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _analyze_location_context(self, city: str, address: str, alerts: list) -> LocationIntelligenceSchema:
        """
        Uses Gemini 2.5 Flash to generate personalized location safety recommendations.
        """
        if not self.client:
            await asyncio.sleep(0.5)
            return LocationIntelligenceSchema(
                detected_city=city,
                formatted_address=address,
                nearby_alerts=alerts,
                ai_recommendation=f"Mock AI: Avoid main roads in {city} due to reported alerts."
            )

        prompt = f"""
        You are the ZEUS Smart City Location Intelligence Agent.
        The user is currently located at: {address} ({city}).
        
        Nearby Active Alerts:
        {json.dumps(alerts, indent=2)}
        
        Generate a smart safety recommendation for the user based strictly on these alerts and their location.
        Keep it concise and actionable.
        """
        
        for attempt in range(self.max_retries):
            try:
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=LocationIntelligenceSchema,
                        temperature=0.2,
                    )
                )
                
                data = json.loads(response.text)
                # Enforce the factual location and alerts into the structured response
                data["detected_city"] = city
                data["formatted_address"] = address
                data["nearby_alerts"] = alerts
                
                return LocationIntelligenceSchema(**data)
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt)

    async def execute(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        Antigravity Orchestration Hook.
        Receives 'lat' and 'lng'.
        """
        logger.info(f"{self.agent_id} processing location payload...")
        lat = payload.get("lat")
        lng = payload.get("lng")
        
        if lat is None or lng is None:
            return {"status": "failed", "error": "Missing 'lat' or 'lng' in payload."}

        # 1. Reverse Geocode Coordinates
        geo_data = await self.geocoding_service.reverse_geocode(lat, lng)
        if not geo_data:
            return {"status": "failed", "error": "Failed to resolve coordinates to a city."}
            
        city = geo_data.get("city", "Unknown")
        address = geo_data.get("formatted_address", "Unknown")

        # 2. Fetch Nearby Crisis Alerts
        nearby_alerts = await self.alert_service.get_nearby_alerts(lat, lng)

        # 3. AI Safety Context Generation
        try:
            intel = await self._analyze_location_context(city, address, nearby_alerts)
            return {
                "status": "success",
                "data": intel.model_dump()
            }
        except Exception as e:
            logger.critical(f"Location Intelligence Pipeline failed: {str(e)}", exc_info=True)
            return {"status": "failed", "error": str(e)}
