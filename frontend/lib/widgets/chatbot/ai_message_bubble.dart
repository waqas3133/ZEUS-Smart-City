import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AiMessageBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final String? intent;
  final String? riskLevel;
  final List<String> recommendations;

  const AiMessageBubble({
    super.key,
    required this.isUser,
    required this.text,
    this.intent,
    this.riskLevel,
    required this.recommendations,
  });

  Color _getRiskColor() {
    if (riskLevel == null) return Colors.white30;
    switch (riskLevel!.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return const Color(0xFFFF007F); // Red
      case 'MODERATE':
        return Colors.orangeAccent;
      default:
        return const Color(0xFF00E5FF); // Cyan
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00E5FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    // AI Glassmorphic response bubble
    final hasRisk = riskLevel != null && (riskLevel == 'HIGH' || riskLevel == 'CRITICAL');
    final riskColor = _getRiskColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassmorphicContainer(
          width: MediaQuery.of(context).size.width * 0.8,
          height: recommendations.isNotEmpty ? 220 : 120,
          borderRadius: 20,
          blur: 15,
          border: 1.5,
          linearGradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              hasRisk ? const Color(0xFFFF007F) : const Color(0xFF00E5FF).withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header tags if not general chat
                if (intent != null && intent != 'General Chat') ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: riskColor),
                        ),
                        child: Text(
                          'RISK: $riskLevel',
                          style: TextStyle(color: riskColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        intent!,
                        style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                // AI Statement Text
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                    ),
                  ),
                ),
                // Bullet points recommendations
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 6),
                  const Text(
                    'Safety Guidance:',
                    style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recommendations.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
                              Expanded(
                                child: Text(
                                  recommendations[idx],
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
