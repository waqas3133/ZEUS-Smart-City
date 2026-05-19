import math
import logging
from typing import List, Dict, Any
from app.services.alert_dispatcher import AlertDispatcher

logger = logging.getLogger(__name__)

class UserAlertManager:
    """
    Evaluates citizen GPS locations and dispatches localized alerts to users within geofence limits.
    """
    def __init__(self):
        self.dispatcher = AlertDispatcher()
        logger.info("UserAlertManager initialized.")

    def haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Computes geographic distance in kilometers between two GPS coordinates.
        """
        R = 6371.0 # Earth's radius in km
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        
        a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        return R * c

    async def alert_nearby_users(
        self,
        incident_lat: float,
        incident_lng: float,
        event_name: str,
        danger_summary: str,
        active_users: List[Dict[str, Any]],
        radius_km: float = 2.0
    ) -> int:
        """
        Identifies users within the danger radius and dispatches immediate warning overlay pushes.
        """
        dispatched_count = 0
        logger.info(f"Checking {len(active_users)} active users near incident at ({incident_lat}, {incident_lng}) within {radius_km}km geofence...")

        for user in active_users:
            u_lat = user.get("latitude")
            u_lng = user.get("longitude")
            fcm_token = user.get("fcm_token")

            if u_lat is None or u_lng is None or not fcm_token:
                continue

            dist = self.haversine_distance(incident_lat, incident_lng, u_lat, u_lng)
            if dist <= radius_km:
                logger.info(f"Target user '{user.get('uid')}' identified at {dist:.2f}km. Dispatching geofenced alarm.")
                
                title = "⚠️ IMMEDIATE HAZARD DETECTED NEAR YOU"
                body = f"Danger: {event_name}. {danger_summary}. Seek alternate bypasses immediately."
                
                data = {
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    "type": "GEOPUSH",
                    "lat": str(incident_lat),
                    "lng": str(incident_lng),
                    "event": event_name,
                    "summary": danger_summary
                }

                await self.dispatcher.send_direct_user_alert(fcm_token, title, body, data)
                dispatched_count += 1

        return dispatched_count
