import asyncio
import logging
import json
from typing import Dict, Any, Optional
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.weather_service import WeatherService
from .weather_schemas import WeatherIntelligenceSchema
from .weather_prompts import WEATHER_SYSTEM_PROMPT, build_weather_prompt

logger = logging.getLogger(__name__)

class WeatherIntelligenceAgent:
    """
    Enterprise-grade AI Weather Agent for ZEUS Smart City.
    Analyzes OpenWeather data with Gemini 2.5 to predict severe events.
    """
    def __init__(self, agent_id: str = "weather-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        self.weather_service = WeatherService()
        
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized WeatherIntelligenceAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _call_gemini_with_retry(self, prompt: str) -> WeatherIntelligenceSchema:
        """
        Executes the LLM call with an exponential backoff retry mechanism.
        """
        for attempt in range(self.max_retries):
            try:
                full_prompt = f"{WEATHER_SYSTEM_PROMPT}\\n\\n{prompt}"
                
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=full_prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=WeatherIntelligenceSchema,
                        temperature=0.1, 
                    )
                )
                
                data = json.loads(response.text)
                return WeatherIntelligenceSchema(**data)
                
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt)

    async def execute(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        Main Antigravity Orchestration Hook.
        Receives an event payload containing a 'city'.
        """
        logger.info(f"{self.agent_id} processing payload...")
        city = payload.get("city", "")
        
        if not city:
            return {
                "status": "failed",
                "error": "Missing 'city' in payload."
            }

        # Step 1: Fetch raw weather data
        raw_weather_data = await self.weather_service.get_current_weather(city)
        if not raw_weather_data:
            return {
                "status": "failed",
                "error": f"Failed to fetch weather data for city: {city}"
            }

        # Step 2: Use AI to analyze the data
        if not self.client:
            # Mock mode
            await asyncio.sleep(0.5)
            return {
                "status": "success",
                "data": WeatherIntelligenceSchema(
                    city=city,
                    weather_condition="Heavy Rain",
                    temperature=30.5,
                    humidity=85.0,
                    rain_probability=0.95,
                    storm_probability=0.60,
                    flood_risk="HIGH",
                    alert_level="SEVERE",
                    recommended_actions=["Move to higher ground", "Avoid driving"],
                    ai_summary=f"⚠ Heavy rain expected in {city} within 30 minutes.",
                    reasoning="Mock mode activated due to missing API key."
                ).model_dump()
            }

        try:
            prompt = build_weather_prompt(city, raw_weather_data)
            structured_result = await self._call_gemini_with_retry(prompt)
            
            return {
                "status": "success",
                "data": structured_result.model_dump()
            }
        except Exception as e:
            logger.critical(f"Weather Intelligence Pipeline failed: {str(e)}", exc_info=True)
            return {
                "status": "failed",
                "error": str(e)
            }
