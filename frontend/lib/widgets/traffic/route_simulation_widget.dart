import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class RouteSimulationWidget extends StatelessWidget {
  final double beforeCongestion;
  final double afterCongestion;
  final int beforeTimeMins;
  final int afterTimeMins;
  final int timeSavedMins;

  const RouteSimulationWidget({
    super.key,
    required this.beforeCongestion,
    required this.afterCongestion,
    required this.beforeTimeMins,
    required this.afterTimeMins,
    required this.timeSavedMins,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 180,
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
          const Color(0xFFFF007F).withOpacity(0.2),
          const Color(0xFF00E5FF).withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Color(0xFF00E5FF), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'REROUTING OPTIMIZATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${((beforeCongestion - afterCongestion) * 100).toInt()}% Traffic',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Congestion Index Before vs After
            Row(
              children: [
                const SizedBox(
                  width: 70,
                  child: Text('Congestion:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Before
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: beforeCongestion,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: const Color(0xFFFF007F),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(beforeCongestion * 100).toInt()}%',
                            style: const TextStyle(color: Color(0xFFFF007F), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // After
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: afterCongestion,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: const Color(0xFF00E5FF),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(afterCongestion * 100).toInt()}%',
                            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Time Saved Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeMetric('BEFORE', '$beforeTimeMins mins', const Color(0xFFFF007F)),
                _buildTimeMetric('AFTER AI', '$afterTimeMins mins', const Color(0xFF00E5FF)),
                _buildTimeMetric('SAVED', '$timeSavedMins mins', Colors.greenAccent, isHighlight: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric(String label, String value, Color color, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isHighlight ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
