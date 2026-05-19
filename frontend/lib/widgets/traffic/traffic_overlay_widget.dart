import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TrafficOverlayWidget extends StatelessWidget {
  final String status;
  final String delay;
  final String riskLevel;
  final String recommendation;
  final List<String> blockedRoutes;

  const TrafficOverlayWidget({
    super.key,
    required this.status,
    required this.delay,
    required this.riskLevel,
    required this.recommendation,
    required this.blockedRoutes,
  });

  Color _getRiskColor() {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return const Color(0xFFFF007F); // Pink/Red
      case 'MODERATE':
        return Colors.orangeAccent;
      default:
        return const Color(0xFF00E5FF); // Cyan/Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 190,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.black.withOpacity(0.6),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getRiskColor()),
                  ),
                  child: Text(
                    'RISK: $riskLevel',
                    style: TextStyle(
                      color: _getRiskColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  delay,
                  style: const TextStyle(
                    color: Color(0xFFFF007F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Blocked routes indicator
            if (blockedRoutes.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.block, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Blocked: ${blockedRoutes.join(", ")}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // AI Recommendation
            const Text(
              'AI Route Recommendation:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  recommendation,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
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
