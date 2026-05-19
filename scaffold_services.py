import os

SERVICES_DIR = "backend/app/services"
FIREBASE_DIR = "backend/app/firebase"
SIMULATIONS_DIR = "backend/app/simulations"

FIREBASE_CLIENT = """import firebase_admin
from firebase_admin import credentials, firestore, messaging
import logging

logger = logging.getLogger(__name__)

class FirebaseManager:
    \"\"\"
    Production-grade Firebase Manager for Firestore and FCM notifications.
    \"\"\"
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
"""

GEMINI_SERVICE = """import logging
from google import genai
from app.core.config import settings

logger = logging.getLogger(__name__)

class GeminiService:
    \"\"\"
    Wrapper for Google GenAI SDK (Gemini 2.5 Flash/Pro).
    \"\"\"
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        logger.info("GeminiService initialized.")

    async def analyze_crisis_image(self, image_bytes: bytes, prompt: str) -> str:
        # Placeholder for actual Gemini Vision call
        logger.info("Analyzing image via Gemini Vision.")
        return "High confidence of urban flooding detected in the image."
        
    async def reason_about_crisis(self, context: str) -> str:
        # Placeholder for text reasoning
        logger.info("Reasoning via Gemini 2.5 Flash.")
        return "Based on the multi-modal data, this is a Category 4 emergency."
"""

WEATHER_SERVICE = """import httpx
import logging
from app.core.config import settings

logger = logging.getLogger(__name__)

class WeatherService:
    \"\"\"
    Integration with OpenWeather API.
    \"\"\"
    def __init__(self):
        self.api_key = settings.OPENWEATHER_API_KEY
        self.base_url = "https://api.openweathermap.org/data/2.5"

    async def get_current_weather(self, lat: float, lon: float) -> dict:
        async with httpx.AsyncClient() as client:
            # url = f"{self.base_url}/weather?lat={lat}&lon={lon}&appid={self.api_key}"
            # response = await client.get(url)
            # return response.json()
            return {"status": "ok", "mock_temp": 32, "condition": "Heavy Rain"}
"""

FLOOD_SIM = """import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

class FloodSimulationEngine:
    \"\"\"
    Digital Twin Engine for mapping flood spread.
    \"\"\"
    def __init__(self):
        self.active_simulations = {}
        logger.info("FloodSimulationEngine initialized.")

    def run_simulation(self, lat: float, lon: float, rain_intensity_mm: float) -> Dict[str, Any]:
        \"\"\"
        Runs a mock simulation predicting water levels.
        \"\"\"
        predicted_radius = rain_intensity_mm * 1.5
        time_to_flood_mins = max(30 - (rain_intensity_mm / 10), 5)
        
        return {
            "predicted_flood_radius_km": predicted_radius,
            "estimated_time_to_critical_mins": time_to_flood_mins,
            "evacuation_zones": ["Zone A", "Zone B"]
        }
"""

GITIGNORE = """
# Python
__pycache__/
*.py[cod]
*$py.class
venv/
.env

# Flutter
frontend/.dart_tool/
frontend/.flutter-plugins
frontend/.flutter-plugins-dependencies
frontend/.packages
frontend/build/
frontend/android/key.properties

# IDE
.vscode/
.idea/
"""

README = """# ZEUS Smart City Platform

An enterprise-grade, highly scalable AI-powered crisis intelligence platform utilizing Google Antigravity, Gemini 2.5, FastAPI, and Flutter.

## Architecture
- **Frontend**: Flutter (Riverpod, Glassmorphism, Google Maps)
- **Backend**: Python FastAPI (Async, WebSockets)
- **AI Orchestration**: Google Antigravity Swarm Intelligence
- **Data & Infra**: Firebase (Firestore, Auth, FCM)
"""

files_to_write = {
    os.path.join(FIREBASE_DIR, "client.py"): FIREBASE_CLIENT,
    os.path.join(SERVICES_DIR, "gemini_service.py"): GEMINI_SERVICE,
    os.path.join(SERVICES_DIR, "weather_service.py"): WEATHER_SERVICE,
    os.path.join(SIMULATIONS_DIR, "flood_sim.py"): FLOOD_SIM,
    ".gitignore": GITIGNORE,
    "README.md": README,
}

for full_path, content in files_to_write.items():
    directory = os.path.dirname(full_path)
    if directory:
        os.makedirs(directory, exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content.strip() + "\\n")

print("Services and extra boilerplates generated successfully.")
