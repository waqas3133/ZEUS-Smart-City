import httpx
import logging
from typing import Dict, Any, Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

class GeocodingService:
    """
    Enterprise wrapper for Google Maps Geocoding API.
    Converts coordinates to city/location names and vice-versa.
    """
    def __init__(self):
        self.api_key = settings.GOOGLE_MAPS_API_KEY
        self.base_url = "https://maps.googleapis.com/maps/api/geocode/json"

    async def reverse_geocode(self, lat: float, lng: float) -> Optional[Dict[str, Any]]:
        """
        Converts lat/lng to a readable address and city.
        """
        if not self.api_key:
            logger.warning("GOOGLE_MAPS_API_KEY missing. Returning mock geocoding data.")
            return self._get_mock_location(lat, lng)

        url = f"{self.base_url}"
        params = {
            "latlng": f"{lat},{lng}",
            "key": self.api_key
        }
        
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                status = data.get("status")
                if status == "OK" and data.get("results"):
                    result = data["results"][0]
                    city = "Unknown"
                    for comp in result.get("address_components", []):
                        if "locality" in comp.get("types", []) or "administrative_area_level_1" in comp.get("types", []):
                            city = comp.get("long_name")
                            break
                            
                    return {
                        "city": city,
                        "formatted_address": result.get("formatted_address")
                    }
                
                logger.warning(f"Google Maps Geocoding API returned status: {status}. Response payload: {data}. Falling back to mock location coordinates.")
                return self._get_mock_location(lat, lng)
        except Exception as e:
            logger.error(f"Geocoding failed for {lat},{lng}: {str(e)}. Falling back to mock location coordinates.")
            return self._get_mock_location(lat, lng)

    def _get_mock_location(self, lat: float, lng: float) -> Dict[str, Any]:
        """
        Helper to return high-quality mock data when Google API is restricted or key is invalid.
        """
        # Match coordinates to common Pakistani cities
        city = "Islamabad"
        if 31.0 <= lat <= 32.0:
            city = "Lahore"
        elif 24.0 <= lat <= 25.5:
            city = "Karachi"
            
        return {
            "city": city,
            "country": "Pakistan",
            "formatted_address": f"Street {int(lat*10)%50}, Sector F-{int(lng*10)%10 + 1}, {city}, Pakistan",
            "mock_mode": True
        }
