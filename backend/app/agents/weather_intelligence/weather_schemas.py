from pydantic import BaseModel, Field
from typing import List

class WeatherIntelligenceSchema(BaseModel):
    city: str = Field(..., description="The city name being analyzed")
    weather_condition: str = Field(..., description="General condition (e.g., Heavy Rain, Thunderstorm, Clear)")
    temperature: float = Field(..., description="Temperature in Celsius")
    humidity: float = Field(..., description="Humidity percentage")
    rain_probability: float = Field(..., description="Probability of rain in the next 30 minutes (0.0 to 1.0)")
    storm_probability: float = Field(..., description="Probability of a severe storm (0.0 to 1.0)")
    flood_risk: str = Field(..., description="Risk of flooding: LOW, MODERATE, HIGH, CRITICAL")
    alert_level: str = Field(..., description="Priority alert level: INFO, WARNING, SEVERE, URGENT")
    recommended_actions: List[str] = Field(default_factory=list, description="Safety guidance for the public")
    ai_summary: str = Field(..., description="A short user-friendly AI summary of the weather threat")
    reasoning: str = Field(..., description="Internal reasoning on why these probabilities and risks were chosen")
