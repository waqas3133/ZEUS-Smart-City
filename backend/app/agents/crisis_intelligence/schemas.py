from pydantic import BaseModel, Field
from typing import List

class CrisisIntelligenceSchema(BaseModel):
    event_type: str = Field(..., description="Type of emergency, e.g., Urban Flooding, Heavy Rain, Accident, None")
    severity: str = Field(..., description="Severity of the situation: LOW, MODERATE, HIGH, CRITICAL")
    confidence: float = Field(..., description="Confidence score from 0.0 to 1.0")
    affected_area: str = Field(..., description="Specific location mentioned, or 'Unknown' if not specified")
    impact: List[str] = Field(default_factory=list, description="Possible immediate impacts, e.g., 'Road block', 'Power outage'")
    recommended_actions: List[str] = Field(default_factory=list, description="List of immediate safety recommendations")
    alert_priority: str = Field(..., description="Priority of the alert: INFO, WARNING, URGENT")
    reasoning: str = Field(..., description="Brief reasoning of how the AI interpreted the text and reached the conclusion")
