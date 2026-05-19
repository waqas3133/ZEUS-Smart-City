import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

class CongestionAnalyzer:
    """
    Analyzes street speeds, flows, and calculates Congestion Indexes and delay values.
    """
    def __init__(self):
        logger.info("CongestionAnalyzer initialized.")

    def calculate_congestion_index(self, free_flow_speed: float, current_speed: float) -> float:
        """
        Calculates congestion on a scale of 0.0 (empty road) to 1.0 (blocked road).
        """
        if free_flow_speed <= 0:
            return 0.0
            
        ratio = current_speed / free_flow_speed
        index = max(0.0, min(1.0, 1.0 - ratio))
        return round(index, 2)

    def estimate_delay_seconds(self, route_length_meters: float, current_speed_kmh: float, free_flow_speed_kmh: float) -> int:
        """
        Estimates the exact travel delay in seconds.
        """
        if current_speed_kmh <= 0 or free_flow_speed_kmh <= 0:
            return 0

        # Convert speed to meters per second
        free_flow_mps = (free_flow_speed_kmh * 1000) / 3600
        current_mps = (current_speed_kmh * 1000) / 3600

        ideal_time = route_length_meters / free_flow_mps
        actual_time = route_length_meters / current_mps

        delay = max(0.0, actual_time - ideal_time)
        return int(delay)
