import logging
from typing import List

logger = logging.getLogger(__name__)

class SeverityEngine:
    """
    Formulates a structured risk framework based on the density and severity of observed events.
    """
    def __init__(self):
        logger.info("SeverityEngine initialized.")

    def compute_risk_rating(self, objects_count: int, detected_event: str) -> str:
        """
        Determines the safety alert index: LOW, MEDIUM, HIGH, SEVERE.
        """
        if "flood" in detected_event.lower() and objects_count >= 3:
            return "SEVERE"
        elif objects_count >= 4 or "accident" in detected_event.lower():
            return "HIGH"
        elif objects_count >= 2:
            return "MEDIUM"
            
        return "LOW"
