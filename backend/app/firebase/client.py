import firebase_admin
from firebase_admin import credentials, firestore, messaging
import logging

logger = logging.getLogger(__name__)

class FirebaseManager:
    """
    Production-grade Firebase Manager for Firestore and FCM notifications.
    """
    def __init__(self, cred_path: str):
        try:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            self.db = firestore.client()
            logger.info("Firebase initialized successfully.")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase: {e}")

    async def push_notification(self, token: str, title: str, body: str, data: dict = None):
        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data=data or {},
                token=token,
            )
            response = messaging.send(message)
            logger.info(f"Successfully sent FCM: {response}")
        except Exception as e:
            logger.error(f"FCM Push failed: {e}")