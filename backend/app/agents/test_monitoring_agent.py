import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from app.agents.monitoring_agent import MonitoringAgent

async def run_tests():
    agent = MonitoringAgent()

    payload = {
        "active_incidents": 3,
        "weather_conditions": "Severe Rain and Thunderstorm Forecast for Lahore Tonight",
        "traffic_congestion": "Heavy congestion on major underpasses and roads"
    }

    print("====================================================")
    print("TESTING AI CITY HEALTH & MONITORING Swarm")
    print("====================================================\n")

    print("[TEST 1] Dispatching live city metrics to Gemini...")
    result = await agent.execute(payload)
    
    if result.status == "success":
        print("Success! Structured Health Profile:")
        print(json.dumps(result.data.model_dump(), ensure_ascii=False, indent=2))
    else:
        print(f"Failed: {result.error}")
    print("\n" + "="*50 + "\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
