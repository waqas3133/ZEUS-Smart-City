import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:io';

class ImagePreviewWidget extends StatelessWidget {
  final String? imagePath;
  final String? severity;
  final VoidCallback onClear;

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    this.severity,
    required this.onClear,
  });

  Color _getSeverityColor() {
    if (severity == null) return const Color(0xFF00E5FF);
    switch (severity!.toUpperCase()) {
      case 'SEVERE':
      case 'CRITICAL':
        return const Color(0xFFFF007F); // Neon Red/Pink
      case 'HIGH':
        return Colors.orangeAccent;
      case 'MEDIUM':
        return Colors.yellowAccent;
      default:
        return const Color(0xFF00E5FF); // Neon Cyan
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: Colors.white30, size: 40),
              SizedBox(height: 8),
              Text(
                'Upload emergency photo or take picture',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    final borderColor = _getSeverityColor();

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview Image
            imagePath == 'SIMULATED_DEMO_FLOOD_ROAD'
                ? Image.network(
                    'https://images.unsplash.com/photo-1547683905-f686c993aae5?auto=format&fit=crop&w=600&q=80',
                    fit: BoxFit.cover,
                  )
                : imagePath!.startsWith('http')
                    ? Image.network(
                        imagePath!,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
            // Clear Button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onClear,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            // Severity Label Badge
            if (severity != null)
              Positioned(
                bottom: 10,
                left: 10,
                child: GlassmorphicContainer(
                  width: 110,
                  height: 32,
                  borderRadius: 8,
                  blur: 10,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      borderColor,
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SEVERITY: $severity',
                      style: TextStyle(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
