import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'microphone_animation.dart';

class VoiceAssistantWidget extends StatefulWidget {
  final Function(String) onVoiceQuery;
  final bool isTTSPlaying;
  final VoidCallback onStopTTS;

  const VoiceAssistantWidget({
    super.key,
    required this.onVoiceQuery,
    required this.isTTSPlaying,
    required this.onStopTTS,
  });

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _recognizedText = "Hold microphone and ask weather/crisis questions...";
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    if (_isListening) {
      // Stopped listening -> simulate speech-to-text resolution
      setState(() {
        _isListening = false;
        _recognizedText = "Recognizing voice signature...";
      });
      _waveController.stop();

      // Trigger standard voice simulation loops
      Future.delayed(const Duration(seconds: 1), () {
        widget.onVoiceQuery("Kal Karachi mein barish hogi?");
        setState(() {
          _recognizedText = "Hold microphone and ask weather/crisis questions...";
        });
      });
    } else {
      // Started listening
      setState(() {
        _isListening = true;
        _recognizedText = "Listening to voice signals (Urdu/English)...";
      });
      _waveController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 250,
      borderRadius: 30,
      blur: 20,
      border: 1.5,
      linearGradient: LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.9),
          Colors.black.withValues(alpha: 0.7),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // Slide indicator
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Speech status copy
            Text(
              _recognizedText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),

            // Speech Wave animations
            if (_isListening)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      final val = (index * 0.15) + _waveController.value;
                      final height = 10 + (25 * (val % 1.0));
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  );
                }),
              )
            else if (widget.isTTSPlaying)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up, color: Color(0xFFFF007F), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Speaking voice replies...',
                    style: TextStyle(color: Color(0xFFFF007F), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    onPressed: widget.onStopTTS,
                  )
                ],
              )
            else
              const SizedBox(height: 20),

            const Spacer(),

            // Main mic container
            MicrophoneAnimation(
              isListening: _isListening,
              onTap: _toggleListening,
            ),
          ],
        ),
      ),
    );
  }
}
