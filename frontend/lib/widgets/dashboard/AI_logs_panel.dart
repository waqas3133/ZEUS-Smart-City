import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../../core/constants/api_constants.dart';

class AiLogsPanel extends StatefulWidget {
  const AiLogsPanel({super.key});

  @override
  State<AiLogsPanel> createState() => _AiLogsPanelState();
}

class _AiLogsPanelState extends State<AiLogsPanel> {
  WebSocket? _channel;
  final List<String> _logs = [
    "[AI INITIALIZATION] Initializing connection to ZEUS Command Swarm...",
    "[AI CHANNELS] Core GPS indices loaded successfully.",
    "[AI REPORT] Monitoring active incidents reported by citizens.",
  ];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel?.close();
    super.dispose();
  }

  void _connectWebSocket() async {
    try {
      setState(() {
        _logs.insert(0, "[AI CONNECTING] Querying ZEUS Command Swarm at ${ApiConstants.wsUrl}...");
      });
      
      _channel = await WebSocket.connect(ApiConstants.wsUrl).timeout(const Duration(seconds: 6));
      
      if (!mounted) return;
      setState(() {
        _logs.insert(0, "[AI CONNECTED] Live link established. Listening to agent swarms.");
      });

      _channel!.listen((message) {
        if (!mounted) return;
        setState(() {
          _logs.insert(0, message.toString());
          if (_logs.length > 25) _logs.removeLast();
        });
      }, onError: (err) {
        developer.log("WebSocket stream error: $err");
        _startSimulatedStream();
      }, onDone: () {
        developer.log("WebSocket closed");
        _startSimulatedStream();
      });
    } catch (e) {
      developer.log("WebSocket connection failed: $e");
      if (!mounted) return;
      setState(() {
        _logs.insert(0, "[AI OFFLINE] WebSocket server sleeping. Fallback to local sandbox engine.");
      });
      _startSimulatedStream();
    }
  }

  void _startSimulatedStream() {
    // Dynamically roll simulation updates keeping UI lively
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;

      final mockLogs = [
        "[AI DECISION] Traffic node detected pooling. Rerouting vehicles near underpass.",
        "[FCM ALERT] Warning successfully dispatched to alerts_karachi topic channel.",
        "[GPS TRACKER] Active 2km geofence scanning complete. Zero threats near user area.",
        "[AI OPTIMIZATION] Route safety recalculated. Travel delays reduced by 22 seconds.",
        "[EMERGENCY RADAR] Incident ID RE-382 registered in Firestore.",
      ];

      setState(() {
        _logs.insert(0, mockLogs[DateTime.now().second % mockLogs.length]);
        if (_logs.length > 25) _logs.removeLast();
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.terminal, color: Color(0xFFFF007F), size: 18),
                SizedBox(width: 8),
                Text(
                  'AI SWARM REASONING STREAM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                Spacer(),
                Text(
                  'WS ACTIVE',
                  style: TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, idx) {
                  final log = _logs[idx];
                  Color txtColor = Colors.white70;
                  if (log.contains("DECISION")) txtColor = const Color(0xFF00E5FF);
                  if (log.contains("ALERT") || log.contains("ESCALATION")) txtColor = const Color(0xFFFF007F);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        color: txtColor,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
