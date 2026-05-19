import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from app.agents.traffic_agent import TrafficAgent

async def run_tests():
    agent = TrafficAgent()

    test_cases = [
        {
            "origin": "Shahrah Faisal, Karachi",
            "destination": "Jinnah International Airport, Karachi",
            "blocked_streets": ["Shahrah Faisal", "Karsaz Road"]
        },
        {
            "origin": "Jinnah Avenue, Islamabad",
            "destination": "Saddar, Rawalpindi",
            "blocked_streets": ["Murree Road"]
        }
    ]

    print("====================================================")
    print("TESTING TRAFFIC INTELLIGENCE AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\n")

    for i, payload in enumerate(test_cases, 1):
        print(f"--- Test Case {i} ---")
        print(f"Route: {payload['origin']} -> {payload['destination']}")
        print(f"Blocked: {payload['blocked_streets']}")
        
        result = await agent.execute(payload)
        
        if result.status == "success":
            print("Output JSON:")
            print(json.dumps(result.data.model_dump(), indent=2))
        else:
            print("Failed:")
            print(result.error)
        print("\n" + "="*50 + "\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
