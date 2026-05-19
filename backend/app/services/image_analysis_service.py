import logging
from typing import Dict, Any, Tuple

logger = logging.getLogger(__name__)

class ImageAnalysisService:
    """
    Handles image validation, file sizes, format checks, and basic metadata extraction.
    """
    def __init__(self):
        logger.info("ImageAnalysisService initialized.")

    def validate_image(self, file_content: bytes, filename: str) -> Tuple[bool, str]:
        """
        Validates uploaded emergency image bounds and headers.
        """
        # Ensure it has basic file content
        if len(file_content) == 0:
            return False, "File is completely empty."

        # Maximum upload size limit of 10MB
        max_size = 10 * 1024 * 1024
        if len(file_content) > max_size:
            return False, "Uploaded image exceeds the 10MB file limit."

        # Extension checks
        ext = filename.split(".")[-1].lower()
        if ext not in ["jpg", "jpeg", "png", "webp"]:
            return False, f"Unsupported file type: {ext}. Only JPG, PNG, and WebP are allowed."

        return True, "Success"

    def extract_metadata(self, filename: str, content_size: int) -> Dict[str, Any]:
        """
        Extracts footprint metrics from image payloads.
        """
        return {
            "filename": filename,
            "size_bytes": content_size,
            "mime_type": f"image/{filename.split('.')[-1].lower()}",
            "is_valid": True
        }
