import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent.parent))

from app.agents.location_intelligence.location_agent import LocationIntelligenceAgent

async def run_tests():
    agent = LocationIntelligenceAgent()

    test_cases = [
        {"lat": 33.6844, "lng": 73.0479},  # Islamabad
        {"lat": 31.5204, "lng": 74.3587},  # Lahore
        {"lat": 24.8607, "lng": 67.0011},  # Karachi
    ]

    print("====================================================")
    print("TESTING LOCATION INTELLIGENCE AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\n")

    for i, coords in enumerate(test_cases, 1):
        print(f"--- Test Case {i} ---")
        print(f"Coordinates: {coords['lat']}, {coords['lng']}")
        
        result = await agent.execute(coords)
        
        if result["status"] == "success":
            print("Output JSON:")
            print(json.dumps(result["data"], indent=2))
        else:
            print("Failed:")
            print(result.get("error"))
        print("\n" + "="*50 + "\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
