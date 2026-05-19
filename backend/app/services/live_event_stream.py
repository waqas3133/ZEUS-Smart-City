import logging
import asyncio
from typing import List
from fastapi import WebSocket

logger = logging.getLogger(__name__)

class LiveEventStream:
    """
    Manages active WebSockets connections to broadcast live rolling AI swarm reasoning logs.
    """
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        logger.info("LiveEventStream manager initialized.")

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(f"New administrator connected to WebSocket stream pool. Total: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
        logger.info(f"Administrator disconnected. Active connections left: {len(self.active_connections)}")

    async def broadcast_log(self, message: str):
        """
        Broadcasts a dynamic status log update to all connected dashboard listeners.
        """
        logger.info(f"Broadcasting AI reasoning log: '{message}'")
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception as e:
                logger.error(f"Failed to broadcast message to socket connection: {e}")
                # Safe auto-disconnect on dead socket
                self.active_connections.remove(connection)
