import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

class ConversationManager:
    """
    Manages in-memory contextual chat histories and conversation states.
    Allows multi-turn conversational agents to preserve user state.
    """
    _sessions: Dict[str, List[Dict[str, str]]] = {}

    def __init__(self):
        logger.info("ConversationManager initialized.")

    def get_history(self, session_id: str) -> List[Dict[str, str]]:
        """
        Gets message history for a specific conversation session.
        """
        if session_id not in self._sessions:
            self._sessions[session_id] = []
        return self._sessions[session_id]

    def add_message(self, session_id: str, role: str, content: str):
        """
        Appends a message statement to the history context.
        """
        history = self.get_history(session_id)
        history.append({"role": role, "content": content})
        
        # Limit memory buffer to last 10 messages for efficiency
        if len(history) > 10:
            history.pop(0)

    def clear_session(self, session_id: str):
        """
        Flushes dialog history.
        """
        if session_id in self._sessions:
            self._sessions[session_id].clear()
            logger.info(f"Cleared context history for session: {session_id}")
