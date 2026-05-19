import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../models/incident_report.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves a user profile to the Firestore `/users` collection
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.uid).set(profile.toMap());
      developer.log("UserProfile for ${profile.uid} successfully saved to Firestore.");
    } catch (e) {
      developer.log("Error saving UserProfile: $e");
      rethrow;
    }
  }

  /// Fetches a user profile from Firestore by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromDocument(doc);
      }
      return null;
    } catch (e) {
      developer.log("Error getting UserProfile: $e");
      rethrow;
    }
  }

  /// Submits a smart city incident report to the Firestore `/emergencies` collection
  Future<void> submitIncidentReport(IncidentReport report) async {
    try {
      await _db.collection('emergencies').doc(report.id).set(report.toMap());
      developer.log("IncidentReport ${report.id} successfully recorded in Firestore.");
    } catch (e) {
      developer.log("Error submitting IncidentReport: $e");
      rethrow;
    }
  }

  /// Stream of all active incident reports ordered by timestamp
  Stream<List<IncidentReport>> streamIncidentReports() {
    return _db
        .collection('emergencies')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => IncidentReport.fromDocument(doc)).toList();
        });
  }
}
