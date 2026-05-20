import os
import uvicorn
from app.main import app  # یہ آپ کی اصلی FastAPI ایپ کو لوڈ کرے گا

if __name__ == "__main__":
    # ہگنگ فیس کے پورٹ 7860 پر سرور لانچ کرنا
    uvicorn.run(app, host="0.0.0.0", port=7860)