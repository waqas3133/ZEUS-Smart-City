import asyncio
import json
import sys
import logging
import os
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent.parent))

from app.agents.crisis_intelligence.crisis_intelligence_agent import CrisisIntelligenceAgent

async def run_tests():
    agent = CrisisIntelligenceAgent()

    test_cases = [
        "G-10 mein pani bhar gaya hai aur gaariyan phansi hui hain",
        "Heavy storm expected in Lahore after 30 mins",
        "Road blocked near Saddar due to accident",
        "Bhai light chali gayi hai aur khambay gir gaye hain toofan ki wajah se Johar Town mein."
    ]

    print("====================================================")
    print("TESTING CRISIS INTELLIGENCE AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\\n")

    for i, test_text in enumerate(test_cases, 1):
        print(f"--- Test Case {i} ---")
        print(f"Input: '{test_text}'")
        
        payload = {"report_text": test_text}
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
