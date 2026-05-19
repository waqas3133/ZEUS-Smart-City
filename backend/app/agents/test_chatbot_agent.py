import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from app.agents.chatbot_agent import ChatbotAgent

async def run_tests():
    agent = ChatbotAgent()

    test_cases = [
        {
            "query": "Kal Karachi mein barish hogi?",
            "session_id": "test_session_1"
        },
        {
            "query": "G-10 area safe hai?",
            "session_id": "test_session_1"
        }
    ]

    print("====================================================")
    print("TESTING CHATBOT INTELLIGENCE AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\n")

    for i, payload in enumerate(test_cases, 1):
        print(f"--- Test Case {i} ---")
        print(f"User Query: '{payload['query']}'")
        print(f"Session: '{payload['session_id']}'")
        
        result = await agent.execute(payload)
        
        if result.status == "success":
            print("Output JSON:")
            print(json.dumps(result.data.model_dump(), ensure_ascii=False, indent=2))
        else:
            print("Failed:")
            print(result.error)
        print("\n" + "="*50 + "\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
