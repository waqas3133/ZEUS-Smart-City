import asyncio
import json
import sys
import logging
from pathlib import Path

# Setup simple console logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Add backend directory to path so we can import app
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from app.agents.vision_agent import VisionAgent

async def run_tests():
    agent = VisionAgent()

    # Create dummy JPEG bytes (valid simple header + size)
    dummy_jpeg_bytes = b'\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00' + b'\x00' * 50

    payload = {
        "image_bytes": dummy_jpeg_bytes,
        "filename": "flood_test.jpg"
    }

    print("====================================================")
    print("TESTING MULTIMODAL VISION AI AGENT (GEMINI 2.5 FLASH)")
    print("====================================================\n")

    print("Executing visual reasoning swarm pipeline...")
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
