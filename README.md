# ⚡ ZEUS Smart City AI
### *Cognitive Urban Command Center & Swarm Crisis Intelligence*

[![Flutter](https://img.shields.io/badge/Flutter-3.22.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0+-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Messaging-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Google%20Gemini-2.5%20Flash%20%7C%20Pro-4285F4?style=for-the-badge&logo=google-gemini&logoColor=white)](https://ai.google.dev)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)
[![Render](https://img.shields.io/badge/Render-Live%20Backend-46E3B7?style=for-the-badge&logo=render&logoColor=black)](https://render.com)

Welcome to **ZEUS Smart City AI** (Zero-Latency Emergency Urban Swarm), a next-generation cognitive urban coordination framework designed to predict, monitor, and mitigate urban crises. By combining real-time multi-agent swarm intelligence, geolocated threat analytics, computer vision hazard classification, and state-of-the-art Flutter development, ZEUS transforms unstructured citizen telemetry into immediate municipal action.

---

## 🗺️ Project Structure & Directory Layout

```bash
ZEUS-Smart-City/
├── .env.example                # Configuration templates for Google & Firebase services
├── README.md                   # Platform documentation
├── setup_folders.ps1           # Environment setup shell script
├── backend/                    # FastAPI python cloud microservices
│   ├── Dockerfile              # Production container blueprint for Render/Cloud Run
│   ├── requirements.txt        # Backend dependencies listing
│   └── app/
│       ├── main.py             # FastAPI HTTP & WebSockets gateway
│       ├── core/config.py      # BaseSettings configuration with Pydantic
│       ├── api/routes/         # Router groups (Traffic, Weather, Chat, Alerts)
│       ├── agents/             # Autonomous AI Swarm Agents (Pydantic + Gemini SDK)
│       ├── firebase/client.py  # Firestore connection & Firebase Admin client
│       └── services/           # Congestion, routing, weather & simulator services
└── frontend/                   # Multi-platform Flutter app workspace
    ├── pubspec.yaml            # Dart dependency configurations
    ├── android/                # Native Android build & coordinates configurations
    │   └── app/src/main/AndroidManifest.xml # GPS Permissions & Google Maps Key
    └── lib/
        ├── main.dart           # App startup bootstrapper
        ├── core/
        │   ├── theme/          # Cyberpunk theme system (Neon Cyan, Space Blue)
        │   └── router/         # GoRouter state-based navigation graph
        ├── providers/          # Riverpod state providers & Demo playbooks
        ├── screens/            # Cyberpunk dashboards (Chat, Maps, Onboarding)
        ├── services/           # Network Clients, Firebase, & Locations
        │   └── web_utils/      # Web-Native compilation boundaries system
        └── widgets/            # Responsive gauges & hackathon overlays
```

---

## 🗺️ Smart City Vision

Modern cities grow dynamically but face critical vulnerabilities from climate change and rapid urbanization (e.g., severe rainfall, flash floods, traffic gridlocks). Traditional emergency dispatch systems operate in silos, suffering from slow communication loops and fragmented data.

**ZEUS Smart City AI** introduces a unified, cognitive, crowd-sensing approach:
1. **Decentralized Telemetry Ingestion**: Citizens serve as sensor nodes, uploading geolocated crisis imagery and chatting with dispatchers in bilingual Urdu, English, or Roman-Urdu.
2. **Cognitive Swarm Orchestration**: An array of autonomous AI agents processes incoming logs, validates severity, runs route recalculations, and flags active crises.
3. **Proactive Swarm Dispatching**: Visual hazards trigger dynamic city routing bypasses, automatically guiding emergency response vehicles around flood blockades and broadcasting geofenced alerts to nearby residents.

---

## 🛠️ System Architecture & Data Flow

ZEUS implements a decoupled, high-performance architecture separating compute-heavy cognitive workflows from responsive client interactions.

### Decoupled System Architecture
```mermaid
graph TD
    subgraph Client Space (Flutter & Dart Engine)
        App[Flutter Core / Web-Native Boundaries]
        Router[GoRouter State Graph]
        Riverpod[Riverpod State Providers]
        MapsSDK[Google Maps SDK]
        Overlay[Hackathon Demo Autoplay Overlay]
    end

    subgraph Firebase Cloud Services
        Auth[Anonymous Auth Gateways]
        Firestore[Realtime Emergencies collection]
        FCM[Firebase Cloud Messaging Topics]
    end

    subgraph FastAPI Orchestrator (Render Hosting)
        FastAPI[FastAPI Server]
        Manager[AntigravityOrchestrator]
        Agents[Multi-Agent Swarm]
        Services[Microservices & Calculators]
    end

    subgraph External Cognitive APIs
        Gemini[Google Gemini 2.5 Flash / Pro]
        OpenWeather[OpenWeather Telemetry API]
    end

    %% Client Connections
    App -->|Dynamic rendering| MapsSDK
    App -->|State routing| Router
    App -->|UI bindings| Riverpod
    Overlay -->|Inject commands| Riverpod

    %% Client to Firebase
    App -->|Auth requests| Auth
    App -->|Stream snapshots| Firestore
    App -->|Token registration| FCM

    %% Client to Backend
    App -->|HTTP Uploads & Websockets| FastAPI

    %% Backend Orchestration
    FastAPI -->|Event ingestion| Manager
    Manager -->|Specialized tasks| Agents
    Agents -->|NLP, Vision, Decisions| Gemini
    Agents -->|Atmospheric data| OpenWeather
    Agents -->|Calculate metrics| Services
    Manager -->|Write updates| Firestore
    Manager -->|Push alert notifications| FCM
```

### 1. Decoupled Flutter-FastAPI Pipeline
The Flutter frontend client communicates with the containerized **FastAPI** backend via high-speed RESTful JSON APIs and persistent WebSocket connections. Heavy image processing, Pydantic validations, and LLM reasoning are offloaded to Python cloud services, keeping client interactions smooth and responsive.

### 2. Live Synchronization & Telemetry Streaming
* **State Management (Riverpod)**: Employs modern `Notifier` and `NotifierProvider` state controllers. UI widgets react dynamically to state changes (such as starting the autoplay demo scenario).
* **Real-time WebSockets Stream**: Active simulation updates, rerouting paths, and telemetry logs are pushed through a persistent WebSocket stream from the server directly to the dashboard, visualizing live crisis events as they unfold.
* **Reactive Firebase Sync**: The client hooks into real-time Firestore stream snapshots (`streamActiveEmergencies()`), updating danger pins on the Google Map in real time when new incidents are reported.

---

## 🧠 Multi-Agent Coordination Engine

The core intelligence of ZEUS is powered by an event-driven AI agent swarm. Orchestrated by the `AntigravityOrchestrator`, specialized agents ingest crisis events, analyze visual/atmospheric conditions, and collaborate to reach a consensus decision.

```mermaid
sequenceDiagram
    autonumber
    actor Client as Citizen / Client (Flutter)
    participant Gateway as FastAPI Router
    participant Orchestrator as AntigravityOrchestrator
    participant Vision as VisionAgent (Gemini 2.5 Flash)
    participant Weather as WeatherAgent (OpenWeather)
    participant Decision as DecisionAgent (Gemini 2.5 Flash)
    participant Firebase as Firebase Firestore & FCM

    Client->>Gateway: Upload incident (Image Bytes + Location Metadata)
    Gateway->>Orchestrator: Ingest Emergency Event
    activate Orchestrator
    Orchestrator->>Vision: execute(payload) [Image Analysis]
    Orchestrator->>Weather: execute(payload) [Atmospheric Context]
    activate Vision
    activate Weather
    Vision-->>Orchestrator: VisionAnalysisResult (detected objects, severity, risk)
    Weather-->>Orchestrator: WeatherResult (current temperature, rain index)
    deactivate Vision
    deactivate Weather
    Orchestrator->>Decision: execute(consolidated_payload)
    activate Decision
    Decision-->>Orchestrator: DecisionAgentResult (master consensus decision)
    deactivate Decision
    Orchestrator->>Firebase: Write to emergencies collection & dispatch FCM push alerts
    Orchestrator-->>Gateway: Orchestration Result Payload
    deactivate Orchestrator
    Gateway-->>Client: WebSockets Live Telemetry / HTTP 201 Response
```

### Agent Roles & Specifications:

| Agent Name | Model | Function | Output Schema (Pydantic) |
| :--- | :--- | :--- | :--- |
| **`VisionAgent`** | `gemini-2.5-flash` | Multimodal analysis of uploaded hazard photographs, object classification, risk scaling. | `VisionAnalysisSchema` (event type, confidence, severity, objects list, safety recommendations) |
| **`ChatbotAgent`** | `gemini-2.5-flash` | Conversational dispatcher handling English, Urdu (اردو), and Roman-Urdu, providing voice-synthesized threat details. | `ChatbotResponseSchema` (intent classification, conversational response, risk grading, safety checklist) |
| **`DecisionAgent`** | `gemini-2.5-flash` | Master coordinator resolving agent inputs into a single municipal emergency action plan. | `CrisisDecisionSchema` (severity level, confidence score, primary crisis type, actions, simulation requirements) |
| **`TrafficAgent`** | `gemini-2.5-flash` | Analyzes blocked road telemetry, calculates bypass routes, and calculates congestion reductions. | `TrafficIntelligenceSchema` (status, blocked routes, recommended routes, delay time, simulated impact index) |
| **`WeatherAgent`** | OpenWeather API | Ingests real-time atmospheric metrics, radar fronts, and temperature changes. | `WeatherResult` (precipitation rate, wind speed, severe storm front vectors) |
| **`NotificationAgent`** | Firebase FCM | Broadcasts urgent push notifications to citizen devices based on geofenced radius alerts. | `NotificationPayload` |
| **`SimulationAgent`** | Python Simulator | Simulates mock responder vehicle paths and routing optimizations. | `SimulationPayload` |

---

## 🎨 Visual Command Center (Aesthetics)

Designed with a high-end, visual command center aesthetic, ZEUS blends rich cyberpunk styling (neon accents, glassmorphic panels, glowing gauges) with clear information design:
- **Cinematic Onboarding**: A responsive multi-page presentation introducing core features (Weather, Traffic, Chatbot, Vision) through slide transitions and smooth micro-animations.
- **Cyberpunk Command Dashboard**: Displays active crisis feeds, interactive system logs, live gauges, and response indicators.
- **Intelligent Route Maps**: Rendered overlay lines showing flood zones in neon pink, current route vectors in cyan, and recalculated bypass paths in neon green.

| **Cinematic Onboarding** | **Command Dashboard** | **Intelligent Rerouting Maps** |
| :---: | :---: | :---: |
| ![Onboarding Mockup](frontend/assets/images/zeus_onboarding.png) | ![Dashboard Mockup](frontend/assets/images/zeus_dashboard.png) | ![Map Mockup](frontend/assets/images/zeus_map.png) |

---

## 🤖 Interactive Demo Playbook Flow

ZEUS includes an automated **Demo Playbook** (`demo_playbook_provider.dart`) that showcases the platform's features step-by-step. Users can launch this interactive flow from the command overlay, which guides them through the following scenarios:

| Step | Screen / Route | Duration | Scenario Description |
| :---: | :--- | :---: | :--- |
| **1** | **ZEUS Core Network** (`/dashboard`) | `6s` | Core dashboard initialization, displaying live event log streams. |
| **2** | **Hazard Radar Monitoring** (`/live-map`) | `9s` | Severe rainstorm approaches the city. Geofenced notifications are broadcasted. |
| **3** | **Urdu AI Chatbot** (`/ai-chatbot`) | `11s` | A citizen queries road safety in Roman-Urdu; ChatbotAgent responds instantly in friendly Roman-Urdu. |
| **4** | **Emergency Dispatch Swarm** (`/traffic-intelligence`) | `13s` | Major expressway flooded. TrafficAgent recalculates paths and simulates bypass runs. |
| **5** | **Citizen Edge Vision Reporting** (`/emergency-upload`) | `11s` | A citizen uploads a flood photo. VisionAgent analyses hazards, lists objects, and logs the report. |
| **6** | **Admin Command Center** (`/admin`) | `8s` | Live admin telemetry panel updates instantly with the verified incident details. |

---

## 🔌 Integration Map & API Setup

Configure the following environment variables in your `.env` file at the workspace root directory:

```bash
# =========================================================================
# ZEUS Smart City Config Key Configurations
# =========================================================================

# --- Google Maps Integration Keys ---
# Google Maps Javascript SDK key (Web) and Native SDK key (Android/iOS)
GOOGLE_MAPS_API_KEY="AIzaSyAqdk4QSDbGIsmJ36Q3jb7ZRrSLvM9CFhQ"

# --- Google Gemini LLM Credentials ---
# API Key from Google AI Studio powering the multi-agent swarm
GEMINI_API_KEY="AIzaSyCh..."

# --- OpenWeather Telemetry APIs ---
# Key for live atmospheric weather forecasting queries
OPENWEATHER_API_KEY="df8160..."

# --- API Connection Endpoints ---
# High availability FastAPI Python Cloud backend hosting endpoint
ZEUS_BACKEND_BASE_URL="http://localhost:8000"

# WebSockets endpoint for live stream analysis logs
ZEUS_BACKEND_WS_URL="ws://localhost:8000"
```

### Key SDK Integrations:
1. **Google Maps SDK**: Rendered dynamically using custom marker icons and route polygons.
2. **Gemini 2.5 Flash (`google-genai`)**: Selected for its fast response times and support for structured Pydantic schemas, enabling reliable data formats.
3. **OpenWeather API**: Monitors temperature, wind speed, and precipitation rates.
4. **Firebase Core SDK**: Manages anonymous user authentication and registers devices to FCM topics for geofenced alerts.

---

## 🤖 Vibe Coding with Antigravity

This platform was developed and stabilized alongside **Google Antigravity**, an agentic AI coding companion. Antigravity resolved critical development bottlenecks to ensure production readiness:

1. **Cross-Platform Web-Native Boundary Isolation**
   To support compiling for both web browsers and native Android, the codebase requires boundary separation. Importing `dart:js_interop` directly inside native mobile builds causes compiler crashes. Antigravity designed a conditional export system:
   - Web bindings are isolated to [web_utils_web.dart](file:///c:/Users/mct/Pictures/ZEUS_Smart_City/frontend/lib/services/web_utils/web_utils_web.dart).
   - [web_utils.dart](file:///c:/Users/mct/Pictures/ZEUS_Smart_City/frontend/lib/services/web_utils/web_utils.dart) detects the compiler target and loads [web_utils_stub.dart](file:///c:/Users/mct/Pictures/ZEUS_Smart_City/frontend/lib/services/web_utils/web_utils_stub.dart) for mobile builds, bypassing the incompatible web dependencies.
   
2. **Android GPS & Maps Manifest Injection**
   Antigravity configured the native Android environment, injecting geolocator requirements (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) and embedding the Google Maps API metadata tags directly into [AndroidManifest.xml](file:///c:/Users/mct/Pictures/ZEUS_Smart_City/frontend/android/app/src/main/AndroidManifest.xml).

3. **Riverpod State Modernization**
   Antigravity refactored deprecated Riverpod APIs, migrating providers to use the modern `Notifier` and `NotifierProvider` model. It also updated color properties to use the new `Color.withValues(alpha:)` API, resolving all Dart analysis warnings.

---

## 💻 Local Installation & Quickstart

### Prerequisites
* **Flutter SDK** (version 3.22.0+)
* **Python** (version 3.10+)
* **Firebase Project** with Firestore, Authentication, and Messaging enabled.

### 1. Repository Setup & Environment
```bash
git clone https://github.com/your-repo/zeus-smart-city.git
cd zeus-smart-city
copy .env.example .env
```

### 2. Configure Firebase
- Place your `google-services.json` in `frontend/android/app/`.
- Download your Firebase Admin private key JSON file, rename it to `firebase_credentials.json`, and place it in the `backend/` directory.
- Update the Firebase configuration options in `frontend/lib/firebase_options.dart`.

### 3. Launch the FastAPI Backend
```bash
cd backend
python -m venv venv

# Windows PowerShell:
.\venv\Scripts\Activate.ps1

# Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
Verify the server is running by visiting `http://localhost:8000/health`.

### 4. Run the Flutter Frontend
```bash
cd ../frontend
flutter pub get

# Run on Web (CanvasKit renderer is recommended for maps performance)
flutter run -d chrome --web-renderer canvaskit

# Run on Mobile (Android / iOS)
flutter run
```

---

## 🚀 Production Deployment Playbook

### 1. Backend Containerization & Deploy
The backend includes a production-ready `Dockerfile` config. To deploy to **Render** or **Google Cloud Run**:
1. Connect your repository to Render.
2. Create a new **Web Service**, set the environment to **Docker**, and select the `backend` directory.
3. Configure the environment variables (`GEMINI_API_KEY`, `OPENWEATHER_API_KEY`, etc.) in the Render dashboard.
4. Set the backend connection URLs in the root `.env` or your environment variables:
   ```bash
   ZEUS_BACKEND_BASE_URL="https://your-backend.onrender.com"
   ZEUS_BACKEND_WS_URL="wss://your-backend.onrender.com"
   ```

### 2. Frontend Web hosting
Build the production-ready web files and deploy to platforms like Firebase Hosting, Vercel, or Netlify:
```bash
flutter build web --web-renderer canvaskit --release
```
The output directory will be generated at `build/web/`, which can be served by any static file hosting service.

---

## 🔮 Future Roadmap

- [ ] **Edge Visual Threat Analysis**: Run lightweight hazard classification models directly on client devices (e.g., using TensorFlow Lite) to reduce server load.
- [ ] **Multi-Vehicle Swarm Simulations**: Scale the dispatch simulator to orchestrate multi-vehicle fleets, coordinating bypass paths for ambulance, police, and rescue swarms simultaneously.
- [ ] **IoT Sensor Grid Integration**: Connect municipal street sensors, water gauges, and weather stations to feed live telemetry directly into the weather agent.
- [ ] **Voice Alert Broadcasting**: Synthesize AI speech advisories into localized emergency alert radio channels during active disasters.
