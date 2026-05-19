import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class SimulationControlPanel extends StatefulWidget {
  const SimulationControlPanel({super.key});

  @override
  State<SimulationControlPanel> createState() => _SimulationControlPanelState();
}

class _SimulationControlPanelState extends State<SimulationControlPanel> {
  double _severitySlider = 3.0;
  bool _reroutingActive = true;

  void _triggerSimulation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulated storm crisis dispatched. Severity level: ${_severitySlider.toStringAsFixed(0)}'),
        backgroundColor: const Color(0xFFFF007F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 240,
      borderRadius: 24,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.02),
          Colors.white.withOpacity(0.005),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.01),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(width: 8),
                Text(
                  'CRISIS SIMULATION TUNER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            
            // Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Simulation Severity', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${_severitySlider.toStringAsFixed(0)} / 5', style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            Slider(
              value: _severitySlider,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: const Color(0xFF00E5FF),
              inactiveColor: Colors.white10,
              onChanged: (val) => setState(() => _severitySlider = val),
            ),
            const SizedBox(height: 6),

            // Toggle
            SwitchListTile(
              value: _reroutingActive,
              onChanged: (val) => setState(() => _reroutingActive = val),
              title: const Text('Auto Bypass Calculations', style: TextStyle(color: Colors.white70, fontSize: 12)),
              subtitle: const Text('Reroutes swarm coordinates', style: TextStyle(color: Colors.white30, fontSize: 9)),
              activeColor: const Color(0xFF00E5FF),
              inactiveTrackColor: Colors.white10,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),

            // Trigger button
            ElevatedButton.icon(
              onPressed: _triggerSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text(
                'DISPATCH CRISIS SIMULATION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
