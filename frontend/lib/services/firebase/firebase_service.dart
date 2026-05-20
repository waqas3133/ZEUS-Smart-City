import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initializes the Firebase application services and configures push messaging.
  Future<void> initialize() async {
    try {
      developer.log("Initializing Firebase push messaging systems...");
      
      if (kIsWeb) {
        if (!isPushSupported()) {
          developer.log("FCM web push messaging is not supported by this browser. Bypassing messaging setup.");
          return;
        }
      }
      
      // Request FCM permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      
      developer.log('User granted FCM permission: ${settings.authorizationStatus}');

      // Fetch FCM Token safely
      String? token;
      try {
        token = await _messaging.getToken();
        developer.log("FCM Token acquired: $token");
      } catch (tokenError) {
        developer.log("Failed to acquire FCM Token (e.g. missing VAPID key or SW error): $tokenError");
      }

      // Setup push messaging callbacks
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log("Push Message received in foreground!");
        if (message.notification != null) {
          developer.log("Notification Title: ${message.notification!.title}");
          developer.log("Notification Body: ${message.notification!.body}");
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log("Push Message clicked by user: ${message.data}");
      });
      
    } catch (e) {
      developer.log("FirebaseService initialization failed: $e");
    }
  }

  /// Anonymous Auth for quick reporting without complex signup barriers
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      developer.log("Signed in anonymously as: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      developer.log("Anonymous authentication failed: $e");
      return null;
    }
  }

  /// Subscribe user to localized city safety alerts
  Future<void> subscribeToCityAlerts(String city) async {
    final topic = 'alerts_${city.toLowerCase().replaceAll(" ", "_")}';
    try {
      await _messaging.subscribeToTopic(topic);
      developer.log("Subscribed successfully to safety alerts topic: $topic");
    } catch (e) {
      developer.log("Failed to subscribe to topic $topic: $e");
    }
  }

  /// Unsubscribe from a city alerts topic
  Future<void> unsubscribeFromCityAlerts(String city) async {
    final topic = 'alerts_${city.toLowerCase().replaceAll(" ", "_")}';
    try {
      await _messaging.unsubscribeFromTopic(topic);
      developer.log("Unsubscribed from alerts topic: $topic");
    } catch (e) {
      developer.log("Failed to unsubscribe from topic $topic: $e");
    }
  }

  /// Stream of active emergency events from Firestore
  Stream<QuerySnapshot> streamActiveEmergencies() {
    return _firestore
        .collection('emergencies')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Submits an emergency crisis report directly to Firestore
  Future<bool> reportEmergency({
    required String eventType,
    required String severity,
    required double latitude,
    required double longitude,
    required String city,
    required String area,
    required String aiSummary,
    required List<String> objects,
    required List<String> actions,
    required String imageUrl,
  }) async {
    try {
      final uid = _auth.currentUser?.uid ?? "anonymous_user";
      
      await _firestore.collection('emergencies').add({
        "reporter_id": uid,
        "detected_event": eventType,
        "severity": severity,
        "risk_level": severity,
        "confidence_score": 0.95,
        "image_url": imageUrl,
        "location": {
          "latitude": latitude,
          "longitude": longitude,
          "city": city,
          "area": area,
        },
        "detected_objects": objects,
        "recommended_actions": actions,
        "ai_summary": aiSummary,
        "status": "active",
        "created_at": FieldValue.serverTimestamp(),
      });
      
      developer.log("Emergency crisis uploaded successfully to Firestore.");
      return true;
    } catch (e) {
      developer.log("Failed to write emergency to Firestore: $e");
      return false;
    }
  }

  /// Log out Auth user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
