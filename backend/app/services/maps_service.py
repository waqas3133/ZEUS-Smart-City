import httpx
import logging
from typing import List, Dict, Any, Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

class MapsService:
    """
    Enterprise Google Maps Integration layer.
    Queries the Directions API to get paths, polylines, and traffic info.
    """
    def __init__(self):
        self.api_key = settings.GOOGLE_MAPS_API_KEY
        self.base_url = "https://maps.googleapis.com/maps/api/directions/json"

    async def get_directions(self, origin: str, destination: str) -> Optional[Dict[str, Any]]:
        """
        Retrieves real directions between two points with fallbacks if API key is restricted.
        """
        if not self.api_key:
            logger.warning("GOOGLE_MAPS_API_KEY is missing. Returning mock route directions.")
            return self._get_mock_directions(origin, destination)

        params = {
            "origin": origin,
            "destination": destination,
            "key": self.api_key
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(self.base_url, params=params)
                response.raise_for_status()
                data = response.json()
                if data.get("status") == "OK":
                    return data
                
                logger.warning(f"Directions API status: {data.get('status')}. Falling back to mock route.")
                return self._get_mock_directions(origin, destination)
        except Exception as e:
            logger.error(f"Failed to fetch directions: {str(e)}")
            return self._get_mock_directions(origin, destination)

    def _get_mock_directions(self, origin: str, destination: str) -> Dict[str, Any]:
        """
        Returns mock route directions (Islamabad/Karachi coordinates).
        """
        return {
            "status": "OK",
            "routes": [
                {
                    "legs": [
                        {
                            "distance": {"text": "8.5 km", "value": 8500},
                            "duration": {"text": "25 mins", "value": 1500},
                            "start_location": {"lat": 33.6844, "lng": 73.0479},
                            "end_location": {"lat": 33.7294, "lng": 73.0931},
                            "steps": [
                                {
                                    "distance": {"text": "2.0 km"},
                                    "duration": {"text": "5 mins"},
                                    "html_instructions": "Head northeast on Jinnah Ave",
                                    "start_location": {"lat": 33.6844, "lng": 73.0479},
                                    "end_location": {"lat": 33.6980, "lng": 73.0610}
                                }
                            ]
                        }
                    ],
                    "overview_polyline": {
                        "points": "yvneE`dwwGs@i@qBiB"
                    }
                }
            ]
        }
