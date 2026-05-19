import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from app.agents.notification_agent import NotificationAgent

async def run_tests():
    agent = NotificationAgent()

    payload_1 = {
        "city": "Karachi",
        "source": "Weather Monitoring Radar",
        "description": "Shadeed toofan aur heavy storm expected near the coastal areas of Karachi in next 30 minutes."
    }

    payload_2 = {
        "city": "Karachi",
        "source": "Weather Monitoring Radar",
        "description": "Shadeed toofan aur heavy storm expected near the coastal areas of Karachi in next 30 minutes."
    }

    print("====================================================")
    print("TESTING AI REAL-TIME ALERT & PRIORITIZATION Swarm")
    print("====================================================\n")

    print("[TEST 1] Dispatching initial storm warning context...")
    result_1 = await agent.execute(payload_1)
    
    if result_1.status == "success":
        print("Success! Structured Alert Payload:")
        print(json.dumps(result_1.data.model_dump(), ensure_ascii=False, indent=2))
    else:
        print(f"Failed: {result_1.error}")

    print("\n" + "-"*40 + "\n")

    print("[TEST 2] Triggering duplicate storm warning (Throttling check)...")
    result_2 = await agent.execute(payload_2)
    print(f"Result Status: {result_2.status}")
    if result_2.status == "throttled":
        print("Success! Smart alert throttling intercepted duplicate warning perfectly.")
        print(json.dumps(result_2.data.model_dump(), ensure_ascii=False, indent=2))
    else:
        print("Throttling test failed.")
    print("\n" + "="*50 + "\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
