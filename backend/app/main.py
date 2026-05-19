from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes.location import router as location_router
from app.api.routes.traffic import router as traffic_router
from app.api.routes.chatbot import router as chatbot_router
from app.api.routes.vision import router as vision_router
from app.api.routes.notifications import router as notifications_router
from app.api.routes.admin import router as admin_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend AI Orchestrator for ZEUS Smart City",
)

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for hackathon development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(location_router, prefix="/api/v1/location", tags=["Location"])
app.include_router(traffic_router, prefix="/api/v1/traffic", tags=["Traffic"])
app.include_router(chatbot_router, prefix="/api/v1/chatbot", tags=["Chatbot"])
app.include_router(vision_router, prefix="/api/v1/vision", tags=["Vision"])
app.include_router(notifications_router, prefix="/api/v1/notifications", tags=["Notifications"])
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": settings.PROJECT_NAME, "version": settings.VERSION}

@app.get("/")
async def root():
    return {"message": "Welcome to ZEUS Smart City API"}
