import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imageUrl;
  final IconData icon;
  final Color accentColor;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingAssets {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: "WEATHER INTELLIGENCE",
      description: "Harness real-time meteorological predictive grids. Anticipate precipitation events, heat maps, and micro-climate patterns dynamically.",
      imageUrl: "https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=600",
      icon: Icons.thunderstorm_outlined,
      accentColor: Color(0xFF00E5FF), // Cyber Cyan
    ),
    OnboardingPageData(
      title: "AI EMERGENCY DETECTION",
      description: "Real-time threat assessments via tactical sensor swarms. Immediate detection of high-risk anomalies, floods, and structural crises.",
      imageUrl: "https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=600",
      icon: Icons.emergency_outlined,
      accentColor: Color(0xFFFF007F), // Neon Pink
    ),
    OnboardingPageData(
      title: "SMART TRAFFIC ROUTING",
      description: "Cognitive swarm intelligence for real-time congestion mitigation. Instant route planning around active flood blockages and incidents.",
      imageUrl: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=600",
      icon: Icons.traffic_outlined,
      accentColor: Color(0xFFFFB300), // Amber Yellow
    ),
    OnboardingPageData(
      title: "VISION AI ANALYSIS",
      description: "Advanced convolutional intelligence running locally and on the cloud. Analyze imagery feeds directly to identify critical urban safety reports.",
      imageUrl: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=600",
      icon: Icons.visibility_outlined,
      accentColor: Color(0xFF00FF87), // Matrix Green
    ),
    OnboardingPageData(
      title: "REAL-TIME ALERTS",
      description: "Hyper-localized push updates to safeguard lives. Smart geofenced notifications keep you fully informed within critical radius thresholds.",
      imageUrl: "https://images.unsplash.com/photo-1557597774-9d273605dfa9?q=80&w=600",
      icon: Icons.notifications_active_outlined,
      accentColor: Color(0xFFBD00FF), // Cyber Purple
    ),
    OnboardingPageData(
      title: "AI ASSISTANT FEATURES",
      description: "Secure chat gateway utilizing LLM models. Query conditions, search local reports, and command automated actions with voice support.",
      imageUrl: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=600",
      icon: Icons.forum_outlined,
      accentColor: Color(0xFF00FFCC), // Mint Cyan
    ),
    OnboardingPageData(
      title: "SMART CITY DASHBOARD",
      description: "An integrated command center at your fingertips. Monitor systems, query logs, track active bypass grids, and orchestrate safety simulations.",
      imageUrl: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=600",
      icon: Icons.dashboard_customize_outlined,
      accentColor: Color(0xFF0066FF), // Digital Blue
    ),
  ];
}
