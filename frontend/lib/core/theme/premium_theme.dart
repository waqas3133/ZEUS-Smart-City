import 'package:flutter/material.dart';

class PremiumTheme {
  // Cinematic Cyber HSL Color Palette
  static const Color obsidianBlack = Color(0xFF07090C);
  static const Color deepSpaceBlue = Color(0xFF0D1117);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color tacticalOrange = Colors.orangeAccent;
  static const Color glassWhite = Colors.white10;

  static ThemeData get darkCyberTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: obsidianBlack,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPink,
        surface: deepSpaceBlue,
        error: neonPink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: obsidianBlack,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
        titleLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        bodyLarge: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        bodyMedium: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIconColor: neonCyan,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonPink),
        ),
      ),
    );
  }

  // Futuristic Glassmorphic Decoration helper
  static BoxDecoration glassBox({
    Color borderColor = Colors.white12,
    double blur = 15,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.02),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }
}
