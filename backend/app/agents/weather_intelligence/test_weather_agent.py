import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent.parent))

from app.agents.weather_intelligence.weather_agent import WeatherIntelligenceAgent

async def run_tests():
    agent = WeatherIntelligenceAgent()

    test_cities = [
        "Islamabad",
        "Lahore",
        "Karachi",
    ]

    print("====================================================")
    print("TESTING WEATHER INTELLIGENCE AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\\n")

    for i, city in enumerate(test_cities, 1):
        print(f"--- Test Case {i} ---")
        print(f"City: '{city}'")
        
        payload = {"city": city}
        result = await agent.execute(payload)
        
        if result["status"] == "success":
            print("Output JSON:")
            print(json.dumps(result["data"], indent=2))
        else:
            print("Failed:")
            print(result.get("error"))
        print("\\n" + "="*50 + "\\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
