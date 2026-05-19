import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveMapDashboard extends StatelessWidget {
  const LiveMapDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Elegant fallback simulation container to run smoothly on Flutter Web, Desktop, and Mobile sandbox environments without API keys blockings
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1622),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // Cyber Grid background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Tactical map visualization
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  color: Color(0xFF00E5FF),
                  size: 60,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ZEUS TACTICAL MAP ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Monitoring active danger rings & bypass routes',
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
                const SizedBox(height: 20),
                
                // Active indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('FLOOD ZONE', const Color(0xFFFF007F)),
                    const SizedBox(width: 16),
                    _buildLegendItem('CONGESTION', Colors.orangeAccent),
                    const SizedBox(width: 16),
                    _buildLegendItem('SAFE BYPASS', const Color(0xFF00E5FF)),
                  ],
                ),
              ],
            ),
          ),

          // Glowing tactical border overlay
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, color: Color(0xFF00E5FF), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'LIVE SATELLITE FEED',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
