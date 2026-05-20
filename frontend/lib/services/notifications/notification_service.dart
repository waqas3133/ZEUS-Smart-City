import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js_interop';

// Extensions on JSObject to query properties safely
extension FCMBrowserExtension on JSObject {
  external JSObject? get navigator;
  external JSObject? get PushManager;
}

extension FCMNavigatorExtension on JSObject {
  external JSObject? get serviceWorker;
}

/// Helper to check if browser supports push notifications and service workers
bool isPushSupported() {
  if (!kIsWeb) return true;
  try {
    final navigator = globalContext.navigator;
    if (navigator == null) return false;
    final serviceWorker = navigator.serviceWorker;
    if (serviceWorker == null) return false;
    
    final pushManager = globalContext.PushManager;
    return pushManager != null;
  } catch (e) {
    return false;
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Request iOS / Android permissions for premium notification alarms
  Future<void> initializeNotifications() async {
    try {
      if (kIsWeb) {
        if (!isPushSupported()) {
          developer.log("FCM web notifications are not supported in this browser. Skipping permission request.");
          return;
        }
      }

      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      developer.log("FCM Permission Status: ${settings.authorizationStatus}");

      // Capture FCM device token safely
      String? token;
      try {
        token = await _fcm.getToken();
        developer.log("Device FCM Registry Token: $token");
      } catch (tokenError) {
        developer.log("Failed to acquire Device FCM Registry Token: $tokenError");
      }

      // Auto-update if user already logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && token != null) {
        await saveTokenToFirestore(currentUser.uid);
      }
    } catch (e) {
      developer.log("FCM NotificationService initialization error: $e");
    }
  }

  /// Saves the FCM token to the user's Firestore document
  Future<void> saveTokenToFirestore(String uid) async {
    try {
      if (kIsWeb && !isPushSupported()) return;

      String? token;
      try {
        token = await _fcm.getToken();
      } catch (e) {
        developer.log("Could not fetch token to save to Firestore: $e");
      }

      if (token != null) {
        await _db.collection('users').doc(uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        developer.log("FCM Registry Token updated in Firestore for user $uid.");
      }
    } catch (e) {
      developer.log("Failed to save FCM token to Firestore: $e");
    }
  }

  /// Exposes a stream of historical weather and emergency alerts from Firestore
  Stream<QuerySnapshot> streamAlertHistory() {
    return _db
        .collection('weather_alerts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Subscribe token to targeted city warning channels
  Future<void> subscribeToCity(String city) async {
    final topic = 'alerts_${city.toLowerCase().replaceFirst(" ", "_")}';
    try {
      await _fcm.subscribeToTopic(topic);
      developer.log("FCM successfully subscribed to topic warning: '$topic'");
    } catch (e) {
      developer.log("FCM topic subscription error: $e");
    }
  }

  /// Unsubscribe from targeted city warning channels
  Future<void> unsubscribeFromCity(String city) async {
    final topic = 'alerts_${city.toLowerCase().replaceFirst(" ", "_")}';
    try {
      await _fcm.unsubscribeFromTopic(topic);
      developer.log("FCM successfully unsubscribed from topic: '$topic'");
    } catch (e) {
      developer.log("FCM topic unsubscription error: $e");
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final alertHistoryStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(notificationServiceProvider).streamAlertHistory();
});
