from pydantic_settings import BaseSettings, SettingsConfigDict
import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent

class Settings(BaseSettings):
    PROJECT_NAME: str = "ZEUS Smart City Platform"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # API Keys
    GEMINI_API_KEY: str = ""
    GOOGLE_MAPS_API_KEY: str = ""
    OPENWEATHER_API_KEY: str = ""
    GOOGLE_SPEECH_TO_TEXT_API_KEY: str = ""
    GOOGLE_TRANSLATION_API_KEY: str = ""
    GOOGLE_APPLICATION_CREDENTIALS: str = ""

    model_config = SettingsConfigDict(
        env_file=os.path.join(BASE_DIR, ".env"),
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
