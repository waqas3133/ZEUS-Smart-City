from fastapi import APIRouter, HTTPException, Body
import logging
from typing import Dict, Any, List
from app.agents.notification_agent import NotificationAgent
from app.services.alert_dispatcher import AlertDispatcher
from app.services.user_alert_manager import UserAlertManager

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/broadcast")
async def broadcast_smart_notification(
    payload: Dict[str, Any] = Body(...)
):
    """
    Ingests weather details, accident logs, or infrastructure updates, compiles a structured
    AI notification, logs the alert to Firestore, and broadcasts to FCM topic channels.
    """
    logger.info(f"Notification broadcast trigger request: {payload}")
    
    city = payload.get("city", "Karachi")
    source = payload.get("source", "Weather Swarm")
    description = payload.get("description", "Heavy storm forecast")

    try:
        # 1. Execute AI Notification swarms to compile alerts
        agent = NotificationAgent()
        result = await agent.execute({
            "city": city,
            "source": source,
            "description": description
        })

        if result.status == "throttled":
            return {
                "status": "throttled",
                "message": "Duplicate warning detected within the 15-minute suppression window. Alert suppressed.",
                "data": result.data.model_dump()
            }

        if result.status != "success":
            raise HTTPException(status_code=500, detail=result.error or "Alert compilation failed.")

        # 2. Dispatch FCM Broadcast
        dispatcher = AlertDispatcher()
        dispatch_ok = await dispatcher.broadcast_city_alert(
            city=city,
            title=result.data.notification_title,
            body=result.data.notification_body,
            data={
                "alert_type": result.data.alert_type,
                "severity": result.data.severity,
                "priority": result.data.priority,
                "recommended_actions": ",".join(result.data.recommended_actions)
            }
        )

        return {
            "status": "success",
            "fcm_dispatched": dispatch_ok,
            "data": result.data.model_dump()
        }
    except Exception as e:
        logger.error(f"Broadcast alert error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/geopush")
async def send_geofenced_warning(
    payload: Dict[str, Any] = Body(...)
):
    """
    Identifies all devices inside the 2km coordinate range of a newly reported incident and
    sends immediate direct FCM alert overrides.
    """
    logger.info(f"FCM Geopush request: {payload}")

    lat = payload.get("latitude")
    lng = payload.get("longitude")
    event = payload.get("event", "Flood Risk")
    summary = payload.get("summary", "Rising water levels spotted.")
    
    # Active simulation sandbox users coordinates list
    mock_users: List[Dict[str, Any]] = payload.get("active_users", [
        {
            "uid": "USER_KARACHI_1",
            "fcm_token": "mock_token_1",
            "latitude": 33.6985,
            "longitude": 73.0615
        },
        {
            "uid": "USER_KARACHI_2",
            "fcm_token": "mock_token_2",
            "latitude": 33.6800,
            "longitude": 73.0500
        }
    ])

    if lat is None or lng is None:
        raise HTTPException(status_code=400, detail="Latitude and Longitude coordinates required.")

    try:
        manager = UserAlertManager()
        sent_count = await manager.alert_nearby_users(
            incident_lat=lat,
            incident_lng=lng,
            event_name=event,
            danger_summary=summary,
            active_users=mock_users,
            radius_km=2.0
        )

        return {
            "status": "success",
            "radius_km": 2.0,
            "scanned_count": len(mock_users),
            "dispatched_count": sent_count
        }
    except Exception as e:
        logger.error(f"Geopush process error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
