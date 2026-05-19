import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer' as developer;

class DemoScenarioStep {
  final String title;
  final String message;
  final Duration delay;
  final String activeModule;

  DemoScenarioStep({
    required this.title,
    required this.message,
    required this.delay,
    required this.activeModule,
  });
}

class DemoState {
  final bool isPlaying;
  final int currentStepIndex;

  DemoState({
    required this.isPlaying,
    required this.currentStepIndex,
  });

  DemoState copyWith({
    bool? isPlaying,
    int? currentStepIndex,
  }) {
    return DemoState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}

class DemoModeNotifier extends Notifier<DemoState> {
  Timer? _timer;

  @override
  DemoState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return DemoState(isPlaying: false, currentStepIndex: -1);
  }

  DemoScenarioStep? get currentStep {
    final idx = state.currentStepIndex;
    if (idx >= 0 && idx < steps.length) {
      return steps[idx];
    }
    return null;
  }

  final List<DemoScenarioStep> steps = [
    DemoScenarioStep(
      title: "Rain Radar Ingestion",
      message: "⚠️ Heavy weather front spotted moving towards Karachi South.",
      delay: const Duration(seconds: 4),
      activeModule: "WEATHER",
    ),
    DemoScenarioStep(
      title: "AI Risk Escalation",
      message: "🤖 Swarm agent elevates Karachi South flood risk to SEVERE.",
      delay: const Duration(seconds: 4),
      activeModule: "AI_DECISION",
    ),
    DemoScenarioStep(
      title: "Geofenced FCM Alarms",
      message: "🔔 Immediate alert broadcast dispatched to 14 active user coordinates.",
      delay: const Duration(seconds: 4),
      activeModule: "FCM",
    ),
    DemoScenarioStep(
      title: "Traffic Route Bypass",
      message: "🗺️ Smart routing calculating alternate paths avoiding Shahrah-e-Faisal underpass.",
      delay: const Duration(seconds: 4),
      activeModule: "MAPS",
    ),
    DemoScenarioStep(
      title: "AI Assist Active",
      message: "💬 Conversational AI ready to counsel citizens in English and Roman Urdu.",
      delay: const Duration(seconds: 4),
      activeModule: "CHATBOT",
    ),
  ];

  void startDemoScenario(BuildContext context) {
    if (state.isPlaying) return;
    state = DemoState(isPlaying: true, currentStepIndex: 0);
    _runNextStep(context);
  }

  void stopDemo() {
    _timer?.cancel();
    state = DemoState(isPlaying: false, currentStepIndex: -1);
  }

  void _runNextStep(BuildContext context) {
    if (state.currentStepIndex >= steps.length) {
      stopDemo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hackathon Autoplay Script Completed Successfully!'),
          backgroundColor: Color(0xFF00E5FF),
        ),
      );
      return;
    }

    final step = steps[state.currentStepIndex];
    developer.log("Executing playbook step: ${step.title}");

    _timer = Timer(step.delay, () {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
      _runNextStep(context);
    });
  }
}

final demoModeProvider = NotifierProvider<DemoModeNotifier, DemoState>(DemoModeNotifier.new);
