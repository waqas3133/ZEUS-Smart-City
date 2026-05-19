from pydantic import BaseModel, Field
from typing import List

class AlertItemSchema(BaseModel):
    alert_id: str = Field(..., description="Unique ID of the alert")
    type: str = Field(..., description="Type of alert, e.g., Urban Flooding, Traffic")
    severity: str = Field(..., description="Severity level, e.g., INFO, MODERATE, HIGH, CRITICAL")
    message: str = Field(..., description="Description of the alert details")
    distance_km: float = Field(..., description="Distance in kilometers from user location")

class LocationIntelligenceSchema(BaseModel):
    detected_city: str = Field(..., description="The city identified from the coordinates")
    formatted_address: str = Field(..., description="The readable address")
    nearby_alerts: List[AlertItemSchema] = Field(default_factory=list, description="Active alerts nearby")
    ai_recommendation: str = Field(..., description="Context-aware recommendation based on location and alerts")
