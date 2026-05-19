import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../core/theme/premium_theme.dart';

class FuturisticWidgets {
  /// Cyber-styled Glassmorphic Neon Button with tactical cutouts
  static Widget cyberButton({
    required String text,
    required VoidCallback onTap,
    Color glowColor = PremiumTheme.neonCyan,
    double height = 52,
    bool isLoading = false,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: height,
      borderRadius: 16,
      blur: 15,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: [
          glowColor.withOpacity(0.25),
          glowColor.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          glowColor,
          Colors.white.withOpacity(0.05),
        ],
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: glowColor)
              : Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2.5,
                  ),
                ),
        ),
      ),
    );
  }

  /// Tactical Diagnostics HUD grid card showing monitoring metrics
  static Widget hudGridCard({
    required String title,
    required String value,
    required IconData icon,
    Color statusColor = PremiumTheme.neonCyan,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
