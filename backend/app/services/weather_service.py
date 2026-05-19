import httpx
import logging
from typing import Dict, Any, Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

class WeatherService:
    """
    Enterprise integration with OpenWeather API.
    """
    def __init__(self):
        self.api_key = settings.OPENWEATHER_API_KEY
        self.base_url = "https://api.openweathermap.org/data/2.5"

    async def get_current_weather(self, city: str) -> Optional[Dict[str, Any]]:
        """
        Fetches real-time weather data for a given city.
        """
        if not self.api_key:
            logger.warning("OPENWEATHER_API_KEY missing. Returning mock weather data.")
            return {
                "name": city,
                "main": {"temp": 30.5, "humidity": 85},
                "weather": [{"main": "Rain", "description": "heavy intensity rain"}],
                "wind": {"speed": 15.0},
                "clouds": {"all": 90}
            }

        url = f"{self.base_url}/weather"
        params = {
            "q": city,
            "appid": self.api_key,
            "units": "metric" # Returns temp in Celsius
        }
        
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                return response.json()
        except Exception as e:
            logger.error(f"Failed to fetch weather for {city}: {str(e)}")
            return None