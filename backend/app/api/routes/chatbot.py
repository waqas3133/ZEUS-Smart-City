from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel, Field
import base64
import logging
from app.agents.chatbot_agent import ChatbotAgent
from app.services.speech_service import SpeechService

logger = logging.getLogger(__name__)
router = APIRouter()
speech_service = SpeechService()

class ChatbotQueryPayload(BaseModel):
    query: str = Field(..., description="Conversational query text")
    session_id: str = Field("default_session", description="Conversation session ID")

@router.post("/query")
async def query_chatbot(payload: ChatbotQueryPayload):
    """
    Exposes conversational exchange interface.
    Maintains session history to support multi-turn dialogues.
    """
    logger.info(f"Chatbot query received: '{payload.query}' for session '{payload.session_id}'")
    agent = ChatbotAgent()
    
    result = await agent.execute({
        "query": payload.query,
        "session_id": payload.session_id
    })
    
    if result.status == "success":
        return {
            "status": "success",
            "confidence": result.confidence_score,
            "data": result.data.model_dump()
        }
    else:
        raise HTTPException(
            status_code=500,
            detail=result.error or "Conversational reasoning model failed."
        )

@router.post("/voice")
async def process_voice_query(
    session_id: str = Form("default_session"),
    audio: UploadFile = File(...)
):
    """
    Ingests user audio files, runs Speech-to-Text, processes via ChatbotAgent,
    synthesizes response audio via Text-to-Speech, and returns metadata + base64 audio.
    """
    logger.info(f"Incoming voice query for session: '{session_id}'")
    
    try:
        # 1. Read uploaded audio bytes
        audio_content = await audio.read()
        
        # 2. Convert Speech to Text (Urdu or English)
        text_query = await speech_service.speech_to_text(audio_content)
        logger.info(f"Speech recognized query text: '{text_query}'")
        
        # 3. Process query through ChatbotAgent
        agent = ChatbotAgent()
        result = await agent.execute({
            "query": text_query,
            "session_id": session_id
        })
        
        if result.status != "success":
            raise HTTPException(status_code=500, detail="Voice processing failed inside chatbot agent.")
            
        # 4. Synthesize AI reply back into Speech
        reply_text = result.data.response
        voice_bytes = await speech_service.text_to_speech(reply_text)
        
        # 5. Base64 encode synthesized WAV output
        voice_base64 = base64.b64encode(voice_bytes).decode("utf-8")
        
        return {
            "status": "success",
            "confidence": result.confidence_score,
            "data": result.data.model_dump(),
            "synthesized_audio": voice_base64
        }
    except Exception as e:
        logger.error(f"Voice query endpoint failure: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
