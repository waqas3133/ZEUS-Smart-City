import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class RecommendationEngine:
    """
    Core engine responsible for parsing crisis intent and generating safety recommendations.
    """
    def __init__(self):
        logger.info("RecommendationEngine initialized.")

    def compile_safety_guidance(self, intent: str, city: str = "Karachi") -> List[str]:
        """
        Compiles actionable instructions for emergency crisis and bad weather parameters.
        """
        if "rain" in intent.lower() or "barish" in intent.lower():
            return [
                "Stay indoors during thunder peaks to minimize lightning risks.",
                "Ensure your devices are charged in case of preventive electrical shutdowns.",
                "Do not stand near electric poles or utility cables."
            ]
        elif "flood" in intent.lower() or "selab" in intent.lower() or "safe" in intent.lower():
            return [
                "Move to elevated structures or upper floors immediately if water levels surge.",
                "Bypass underpasses and heavily flooded expressways entirely.",
                "Keep emergency contact numbers handy (ZEUS Helpline: 1122)."
            ]
        
        return [
            "Monitor live AI weather feeds continuously for quick hazard alerts.",
            "Stay clear of active low-lying drainage zones."
        ]
