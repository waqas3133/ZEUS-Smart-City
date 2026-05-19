import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth/auth_service.dart';
import '../services/firestore/firestore_service.dart';
import '../models/user_profile.dart';
import '../models/incident_report.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return null;
  return ref.watch(firestoreServiceProvider).getUserProfile(authUser.uid);
});

final incidentReportsStreamProvider = StreamProvider<List<IncidentReport>>((ref) {
  return ref.watch(firestoreServiceProvider).streamIncidentReports();
});
