import asyncio
import logging
import json
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

from app.core.config import settings
from app.services.conversation_manager import ConversationManager
from app.services.recommendation_engine import RecommendationEngine

logger = logging.getLogger(__name__)

class ChatbotResponseSchema(BaseModel):
    user_query: str = Field(..., description="The user's original query text")
    intent: str = Field(..., description="Detected intent, e.g. Weather Query, Flood Alert check, General Chat")
    response: str = Field(..., description="AI conversational reply in English, Urdu, or Roman Urdu matching user language")
    risk_level: str = Field(..., description="Crisis danger level: LOW, MODERATE, HIGH, CRITICAL")
    recommendations: List[str] = Field(default_factory=list, description="Actionable safety guidance bullets")
    voice_supported: bool = Field(default=True, description="Whether TTS audio play is supported")

class ChatbotAgentResult(BaseModel):
    status: str = Field(..., description="Status of the agent execution")
    confidence_score: float = Field(..., description="Confidence score from 0.0 to 1.0")
    data: ChatbotResponseSchema = Field(..., description="Structured chatbot response payload")
    error: Optional[str] = None

class ChatbotAgent:
    """
    Production-grade AI Conversational Swarm Agent.
    Interprets English, Urdu, and Roman Urdu statements to deliver localized intelligence.
    """
    def __init__(self, agent_id: str = "chatbot-intel-1"):
        self.agent_id = agent_id
        self.max_retries = 3
        self.conversation_manager = ConversationManager()
        self.rec_engine = RecommendationEngine()

        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
            logger.info(f"Initialized ChatbotAgent [{self.agent_id}] with Gemini API.")
        else:
            self.client = None
            logger.warning(f"GEMINI_API_KEY missing. {self.agent_id} will run in mock mode.")

    async def _call_gemini_with_retry(self, prompt: str) -> ChatbotResponseSchema:
        """
        Executes structured chatbot content generation with retry capabilities.
        """
        for attempt in range(self.max_retries):
            try:
                response = await asyncio.to_thread(
                    self.client.models.generate_content,
                    model='gemini-2.5-flash',
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=ChatbotResponseSchema,
                        temperature=0.3,
                    )
                )
                data = json.loads(response.text)
                return ChatbotResponseSchema(**data)
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {self.agent_id}: {str(e)}")
                if attempt == self.max_retries - 1:
                    raise e
                await asyncio.sleep(2 ** attempt)

    async def execute(self, payload: Dict[str, Any]) -> ChatbotAgentResult:
        """
        Processes conversational statements, retrieving history memory overlays.
        """
        logger.info(f"ChatbotAgent executing processing payload...")
        query = payload.get("query", "")
        session_id = payload.get("session_id", "default_session")

        # 1. Retrieve session history context
        history = self.conversation_manager.get_history(session_id)
        
        # 2. Add new user query to history
        self.conversation_manager.add_message(session_id, "user", query)

        # 3. Simulate or build localized warnings
        intent = "General Chat"
        if "barish" in query.lower() or "rain" in query.lower():
            intent = "Weather Query"
        elif "flood" in query.lower() or "selab" in query.lower() or "safe" in query.lower():
            intent = "Flood Alert Check"

        rec_actions = self.rec_engine.compile_safety_guidance(intent)

        if not self.client:
            # Fallback mock mode
            mock_reply = "Karachi mein kal tez barish ka 78% imkaan hai, baraye meharbani ehtiyat karein."
            if "safe" in query.lower() or "g-10" in query.lower():
                mock_reply = "⚠ G-10 area mein bhari barish ke sabab selab ka khatra (Flood Risk) barkarar hai. Amlam durust nahi."

            structured_res = ChatbotResponseSchema(
                user_query=query,
                intent=intent,
                response=mock_reply,
                risk_level="HIGH" if intent != "General Chat" else "LOW",
                recommendations=rec_actions,
                voice_supported=True
            )
            self.conversation_manager.add_message(session_id, "assistant", mock_reply)
            
            return ChatbotAgentResult(
                status="success",
                confidence_score=0.92,
                data=structured_res
            )

        # 4. Prompt construction for Gemini
        prompt = f"""
        You are the ZEUS Smart City Conversational Intelligence and Crisis AI Assistant.
        You understand English, Urdu (اردو), and Roman Urdu (e.g. "kya haal hai", "barish hogi kal").
        
        User Conversation Session History:
        {json.dumps(history, ensure_ascii=False, indent=2)}
        
        Current User Statement: "{query}"
        
        Compile a response. If the query asks about weather risks, flooding, or safety:
        - Detect risk level: LOW, MODERATE, HIGH, CRITICAL.
        - List actionable safety guidelines.
        - Reply in the EXACT same language/style as the user query (e.g. if Roman Urdu, reply in friendly Roman Urdu. If Urdu, reply in Urdu scripts. If English, reply in English).
        """

        try:
            structured_data = await self._call_gemini_with_retry(prompt)
            # Add AI response to memory
            self.conversation_manager.add_message(session_id, "assistant", structured_data.response)
            
            return ChatbotAgentResult(
                status="success",
                confidence_score=0.97,
                data=structured_data
            )
        except Exception as e:
            logger.critical(f"Chatbot agent loop failed: {str(e)}", exc_info=True)
            fallback_text = "Main abhi aapke sawal ka jawab dene se qasir hoon. Baraye meharbani dubara koshish karein."
            return ChatbotAgentResult(
                status="failed",
                confidence_score=0.0,
                error=str(e),
                data=ChatbotResponseSchema(
                    user_query=query,
                    intent=intent,
                    response=fallback_text,
                    risk_level="LOW",
                    recommendations=["Please try asking again later."],
                    voice_supported=True
                )
            )
