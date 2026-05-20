import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _rainAlerts = true;
  bool _floodAlerts = true;
  bool _trafficAlerts = true;
  bool _criticalBroadcasts = true;
  double _geofenceRadius = 2.0;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification and geofence parameters saved successfully.'),
        backgroundColor: Color(0xFF00E5FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF07090C),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ALERT PREFERENCES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                'AI NOTIFICATION TUNER',
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 12),

              // Settings Glass Card
              GlassmorphicContainer(
                width: double.infinity,
                height: 480,
                borderRadius: 24,
                blur: 15,
                border: 1.5,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Switched preferences
                      SwitchListTile(
                        value: _criticalBroadcasts,
                        onChanged: (val) => setState(() => _criticalBroadcasts = val),
                        title: const Text('Critical Emergency Broadcasts', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Priority red alerts including storms & floods', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        activeColor: const Color(0xFFFF007F),
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      SwitchListTile(
                        value: _rainAlerts,
                        onChanged: (val) => setState(() => _rainAlerts = val),
                        title: const Text('Early Rain Warnings', style: TextStyle(color: Colors.white, fontSize: 13)),
                        subtitle: const Text('Predictive alerts 30 minutes before heavy showers', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        activeColor: const Color(0xFF00E5FF),
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      SwitchListTile(
                        value: _floodAlerts,
                        onChanged: (val) => setState(() => _floodAlerts = val),
                        title: const Text('Urban Flood Alerts', style: TextStyle(color: Colors.white, fontSize: 13)),
                        subtitle: const Text('Active pooling indicators near coordinates', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        activeColor: const Color(0xFF00E5FF),
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      SwitchListTile(
                        value: _trafficAlerts,
                        onChanged: (val) => setState(() => _trafficAlerts = val),
                        title: const Text('Traffic Rerouting Warnings', style: TextStyle(color: Colors.white, fontSize: 13)),
                        subtitle: const Text('Accidents, congestions, and closed underpasses', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        activeColor: const Color(0xFF00E5FF),
                        inactiveTrackColor: Colors.white10,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Geofencing tuner card
              const Text(
                'GEOFENCED ALERT LIMITS',
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 12),

              GlassmorphicContainer(
                width: double.infinity,
                height: 130,
                borderRadius: 24,
                blur: 15,
                border: 1.5,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Geofence Distance', style: TextStyle(color: Colors.white, fontSize: 13)),
                          Text('${_geofenceRadius.toStringAsFixed(1)} KM', style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Slider(
                        value: _geofenceRadius,
                        min: 0.5,
                        max: 10.0,
                        divisions: 19,
                        activeColor: const Color(0xFF00E5FF),
                        inactiveColor: Colors.white10,
                        onChanged: (val) => setState(() => _geofenceRadius = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('APPLY SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
