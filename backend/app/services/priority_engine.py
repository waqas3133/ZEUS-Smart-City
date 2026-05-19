import logging
from typing import Dict, Tuple
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class PriorityEngine:
    """
    Evaluates warning severity, computes emergency escalation thresholds,
    and runs alert throttling logic to prevent duplicate notification fatigue.
    """
    def __init__(self):
        # Maps (alert_type, target_area) -> last_dispatched_timestamp
        self._sent_alerts_cache: Dict[Tuple[str, str], datetime] = {}
        # Suppression window limit of 15 minutes
        self.suppression_window = timedelta(minutes=15)
        logger.info("PriorityEngine initialized with a 15-minute suppression window.")

    def should_throttle(self, alert_type: str, target_area: str) -> bool:
        """
        Determines if a duplicate alert for the target area is within the suppression window.
        """
        key = (alert_type.lower(), target_area.lower())
        now = datetime.utcnow()

        if key in self._sent_alerts_cache:
            last_sent = self._sent_alerts_cache[key]
            if now - last_sent < self.suppression_window:
                logger.info(f"Throttling duplicate '{alert_type}' alert for area '{target_area}'. Blocked by cache.")
                return True

        # Update cache timestamp
        self._sent_alerts_cache[key] = now
        return False

    def calculate_priority(self, severity: str, risk_level: str) -> str:
        """
        Computes final push notification priority category: CRITICAL, HIGH, NORMAL.
        """
        sev = severity.upper()
        risk = risk_level.upper()

        if sev == "SEVERE" or risk == "SEVERE":
            return "CRITICAL"
        elif sev == "HIGH" or risk == "HIGH":
            return "HIGH"
        
        return "NORMAL"
