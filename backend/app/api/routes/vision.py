from fastapi import APIRouter, HTTPException, UploadFile, File, Form
import logging
from app.agents.vision_agent import VisionAgent

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/analyze")
async def analyze_emergency_image(
    file: UploadFile = File(...),
    latitude: float = Form(None),
    longitude: float = Form(None)
):
    """
    Ingests physical emergency photographs, executes VisionAgent multimodal Gemini scans,
    and returns immediate threat indices and disaster mapping tags.
    """
    logger.info(f"Incoming Vision analysis request for file: '{file.filename}'")
    
    try:
        # 1. Read uploaded image bytes
        file_bytes = await file.read()
        
        # 2. Execute Vision Agent
        agent = VisionAgent()
        result = await agent.execute({
            "image_bytes": file_bytes,
            "filename": file.filename
        })
        
        if result.status != "success":
            raise HTTPException(
                status_code=500,
                detail=result.error or "Visual reasoning swarm analysis failed."
            )
            
        # 3. Compile map coordinates overlays if available
        location_mapping = None
        if latitude is not None and longitude is not None:
            location_mapping = {
                "lat": latitude,
                "lng": longitude,
                "event": result.data.detected_event,
                "radius_meters": 400 if result.data.severity == "SEVERE" else 200,
                "threat_level": result.data.risk_level
            }
            logger.info(f"Mapped crisis zone successfully at coordinates: ({latitude}, {longitude})")
            
        return {
            "status": "success",
            "confidence": result.confidence_score,
            "data": result.data.model_dump(),
            "danger_zone_mapped": location_mapping
        }
    except Exception as e:
        logger.error(f"Vision query endpoint failure: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
