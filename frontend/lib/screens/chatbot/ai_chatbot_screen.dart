import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../core/constants/api_constants.dart';
import '../../providers/demo_playbook_provider.dart';

import '../../widgets/chatbot/ai_message_bubble.dart';
import '../../widgets/chatbot/voice_assistant_widget.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final String? intent;
  final String? riskLevel;
  final List<String> recommendations;

  ChatMessage({
    required this.isUser,
    required this.text,
    this.intent,
    this.riskLevel,
    this.recommendations = const [],
  });
}

class AiChatbotScreen extends ConsumerStatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  ConsumerState<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends ConsumerState<AiChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _sessionId = "session_${DateTime.now().millisecondsSinceEpoch}";

  bool _isLoading = false;
  bool _isTTSPlaying = false;

  final List<String> _suggestions = [
    "Kal Karachi mein barish hogi?",
    "G-10 area safe hai?",
    "Is there a storm warning?",
  ];

  @override
  void initState() {
    super.initState();
    // Add initial AI welcome message
    _messages.add(
      ChatMessage(
        isUser: false,
        text: "Assalam-o-Alaikum! I am the ZEUS Crisis & Weather AI Assistant. Ask me weather questions or report local emergencies in English, Urdu, or Roman Urdu.",
        intent: "General Chat",
        riskLevel: "LOW",
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: query));
      _isLoading = true;
    });
    _scrollToBottom();
    _textController.clear();

    final dio = Dio(BaseOptions(
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      },
    ));
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/chatbot/query',
        data: {
          "query": query,
          "session_id": _sessionId
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        setState(() {
          _messages.add(
            ChatMessage(
              isUser: false,
              text: data['response'],
              intent: data['intent'],
              riskLevel: data['risk_level'],
              recommendations: List<String>.from(data['recommendations']),
            ),
          );
        });
      }
    } catch (e) {
      developer.log("Failed to contact chatbot API: $e");
      // Fallback sandbox mock replies
      String mockReply = "Assalam-o-Alaikum! Karachi mein kal halki barish ka 78% imkaan hai, baraye meharbani ehtiyat karein.";
      List<String> mockRecs = ["Avoid waterlogged underpasses.", "Keep electronic gadgets fully charged."];
      String mockIntent = "Weather Query";
      String mockRisk = "MODERATE";

      if (query.toLowerCase().contains("safe") || query.toLowerCase().contains("g-10")) {
        mockReply = "⚠ G-10 area mein bhari barish ke sabab selab ka khatra (Flood Risk) barkarar hai. Safar karne se gureez karein.";
        mockRecs = ["Move to higher ground immediately.", "Contact emergency helplines."];
        mockIntent = "Flood Warning";
        mockRisk = "CRITICAL";
      }

      setState(() {
        _messages.add(
          ChatMessage(
            isUser: false,
            text: mockReply,
            intent: mockIntent,
            riskLevel: mockRisk,
            recommendations: mockRecs,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _openVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return VoiceAssistantWidget(
          onVoiceQuery: (recognizedText) {
            Navigator.of(context).pop();
            setState(() {
              _isTTSPlaying = true;
            });
            _sendMessage(recognizedText);
          },
          isTTSPlaying: _isTTSPlaying,
          onStopTTS: () {
            setState(() {
              _isTTSPlaying = false;
            });
          },
        );
      },
    );
  }

  void _startPlaybookAutoChat() async {
    // Wait a brief moment for visual transition
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    
    // Auto-type query in Roman Urdu
    final queryText = "G-10 area me selab ka khatra kitna hai?";
    setState(() {
      _textController.text = "";
    });
    
    for (int i = 1; i <= queryText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      setState(() {
        _textController.text = queryText.substring(0, i);
      });
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    final text = _textController.text;
    _textController.clear();
    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(demoPlaybookProvider, (previous, next) {
      if (next.currentStepIndex == 2) {
        _startPlaybookAutoChat();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Dark space blue
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
        child: Column(
          children: [
            // Conversational Header
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF00E5FF),
                    child: Icon(Icons.support_agent, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ZEUS CRISIS ASSISTANT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                        ),
                        Text(
                          'Active Swarm Intelligence',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.white54),
                    onPressed: _openVoiceAssistant,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Chat Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return AiMessageBubble(
                    isUser: msg.isUser,
                    text: msg.text,
                    intent: msg.intent,
                    riskLevel: msg.riskLevel,
                    recommendations: msg.recommendations,
                  );
                },
              ),
            ),

            // Loading indicators
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('AI Swarm compiling recommendations...', style: TextStyle(color: Colors.white30, fontSize: 10)),
                  ],
                ),
              ),

            // Suggestion chips
            if (_messages.length == 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggest = _suggestions[index];
                      return GestureDetector(
                        onTap: () => _sendMessage(suggest),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Center(
                            child: Text(
                              suggest,
                              style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Composer Text Input Box
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "Ask ZEUS AI weather/crisis...",
                                hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                                border: InputBorder.none,
                              ),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic, color: Color(0xFF00E5FF)),
                            onPressed: _openVoiceAssistant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF00E5FF),
                      child: Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
