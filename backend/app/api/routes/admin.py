from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException, Body
import logging
import asyncio
import json
from typing import Dict, Any
from app.services.dashboard_service import DashboardService
from app.services.analytics_engine import AnalyticsEngine
from app.services.live_event_stream import LiveEventStream
from app.agents.monitoring_agent import MonitoringAgent

logger = logging.getLogger(__name__)
router = APIRouter()
stream_manager = LiveEventStream()

@router.get("/summary")
async def get_summary_metrics():
    """
    Fetches aggregated summary data points across smart alerts and active reports.
    """
    try:
        service = DashboardService()
        metrics = await service.get_dashboard_summary()
        return metrics
    except Exception as e:
        logger.error(f"Dashboard summary fetch error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics")
async def get_analytics_metrics():
    """
    Exposes key city metrics including optimization and risk values.
    """
    try:
        engine = AnalyticsEngine()
        return engine.calculate_metrics()
    except Exception as e:
        logger.error(f"Analytics engine compute error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/simulate-crisis")
async def simulate_smart_crisis(
    payload: Dict[str, Any] = Body(...)
):
    """
    Simulates a crisis scenario, triggers an AI health check, and broadcasts updates.
    """
    incidents = payload.get("active_incidents", 3)
    weather = payload.get("weather", "Heavy Storm Forecast")
    traffic = payload.get("traffic", "Severe Congestion")

    try:
        # 1. Ask Gemini Monitoring agent to evaluate the crisis
        agent = MonitoringAgent()
        health_check = await agent.execute({
            "active_incidents": incidents,
            "weather_conditions": weather,
            "traffic_congestion": traffic
        })

        # 2. Broadcast warnings to WebSocket streams
        log_msg = f"[CRISIS SIMULATED] Danger Rating: {health_check.data.risk_score}% | Guidance: {health_check.data.general_guidance}"
        await stream_manager.broadcast_log(log_msg)

        return {
            "status": "simulated",
            "log_logged": log_msg,
            "risk_analysis": health_check.data.model_dump()
        }
    except Exception as e:
        logger.error(f"Simulate crisis error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.websocket("/ws-logs")
async def websocket_ai_logs(websocket: WebSocket):
    """
    Upgrades incoming network requests to persistent WebSockets.
    Streams mock active alert decision logs every 3 seconds to keep layouts ticking.
    """
    await stream_manager.connect(websocket)
    
    try:
        # Schedulers loop pushing rolling AI decisions to listeners
        while True:
            import random
            events = [
                "[AI DECISION] Traffic monitoring node detected rain pooling. Rerouting 42 vehicles.",
                "[AI WARNING] Geofence active. 8 citizens identified near incident zone in Karachi.",
                "[WEATHER Radars] Precipitation levels increased by 15%. Hazard index: CAUTION.",
                "[AI ESCALATION] Severity rating calculated as SEVERE for underpass pooling near Shahrah Faisal.",
                "[AI DECISION] Alternate bypasses suggested. Shortest safe path saved to route service.",
            ]
            selected_event = random.choice(events)
            await websocket.send_text(selected_event)
            await asyncio.sleep(3.0)
    except WebSocketDisconnect:
        stream_manager.disconnect(websocket)
    except Exception as e:
        logger.error(f"WebSocket admin stream error: {e}")
        stream_manager.disconnect(websocket)
