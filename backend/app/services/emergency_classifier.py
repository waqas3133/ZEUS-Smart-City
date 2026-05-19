import logging
from typing import List

logger = logging.getLogger(__name__)

class EmergencyClassifier:
    """
    Helps categorize identified visual objects and features into specific hazard domains.
    """
    def __init__(self):
        logger.info("EmergencyClassifier initialized.")

    def classify_hazard(self, detected_objects: List[str]) -> str:
        """
        Maps a list of objects observed by the vision system to a clear hazard category.
        """
        objs_lower = [o.lower() for o in detected_objects]
        
        # Check flood triggers
        if any(w in objs_lower for w in ["water", "flood", "flooding", "submerged", "river"]):
            return "Urban Flooding"
            
        # Check accident triggers
        if any(c in objs_lower for c in ["car crash", "accident", "wreckage", "collision"]):
            return "Road Accident"
            
        # Check infrastructure triggers
        if any(i in objs_lower for i in ["fallen tree", "wire", "crater", "debris", "blocked road"]):
            return "Road Blockage / Infrastructure Failure"

        return "Severe Weather Damage"
