import logging
from typing import Dict, Any, Optional
from app.firebase.client import FirebaseManager
from app.core.config import settings

logger = logging.getLogger(__name__)

class AlertDispatcher:
    """
    Production-grade Alert Dispatcher communicating with FCM topic broadcasts and device channels.
    Degrades gracefully to simulated logs if Firebase certificates are missing.
    """
    def __init__(self):
        self.firebase_manager: Optional[FirebaseManager] = None
        
        cred_path = settings.GOOGLE_APPLICATION_CREDENTIALS
        if cred_path:
            if not os.path.isabs(cred_path):
                from app.core.config import BASE_DIR
                resolved_path = os.path.abspath(os.path.join(BASE_DIR, cred_path))
                if os.path.exists(resolved_path):
                    cred_path = resolved_path
                    
        if cred_path and os.path.exists(cred_path):
            try:
                self.firebase_manager = FirebaseManager(cred_path)
                logger.info(f"AlertDispatcher successfully connected to FCM using: {cred_path}")
            except Exception as e:
                logger.error(f"FCM initialization error in AlertDispatcher: {e}")
        else:
            logger.warning(f"FCM credentials missing or invalid at '{cred_path}'. Running AlertDispatcher in sandbox logs mode.")

    async def broadcast_city_alert(self, city: str, title: str, body: str, data: Dict[str, Any]) -> bool:
        """
        Broadcasts an emergency warning to all devices subscribed to a city topic alerts channel.
        """
        topic = f"alerts_{city.lower().replace(' ', '_')}"
        logger.info(f"Broadcasting city-wide alert to topic: '{topic}' -> {title}")
        
        if self.firebase_manager:
            try:
                # Firestore logging
                self.firebase_manager.db.collection('weather_alerts').add({
                    "city": city,
                    "title": title,
                    "body": body,
                    "data": data,
                    "timestamp": firestore.SERVER_TIMESTAMP
                })
                # FCM topic push (Note: messaging supports send_to_topic or topic parameters)
                from firebase_admin import messaging
                message = messaging.Message(
                    notification=messaging.Notification(title=title, body=body),
                    data=data,
                    topic=topic
                )
                response = messaging.send(message)
                logger.info(f"FCM Topic broadcast success: {response}")
                return True
            except Exception as e:
                logger.error(f"FCM Topic broadcast failed: {e}")
                return False
        else:
            # Mock sandbox logger
            logger.info(f"[SANDBOX BROADCAST SUCCESS] Channel: {topic} | Title: {title} | Body: {body}")
            return True

    async def send_direct_user_alert(self, fcm_token: str, title: str, body: str, data: Dict[str, Any]) -> bool:
        """
        Sends a direct localized alert to a specific device.
        """
        if self.firebase_manager:
            await self.firebase_manager.push_notification(fcm_token, title, body, data)
            return True
        else:
            logger.info(f"[SANDBOX DIRECT PUSH SUCCESS] Token: {fcm_token[:8]}... | Title: {title} | Body: {body}")
            return True

import os
from firebase_admin import firestore
