import 'package:firebase_auth/firebase_auth.dart';
import '../firestore/firestore_service.dart';
import '../../models/user_profile.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Gets the stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user getter
  User? get currentUser => _auth.currentUser;

  /// Sign In with Email and Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log("User successfully signed in: ${credentials.user?.uid}");
      return credentials;
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException in signIn: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      developer.log("Unknown error in signIn: $e");
      rethrow;
    }
  }

  /// Sign Up with Email, Password, and updating profile metrics
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
    required String homeCity,
  }) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credentials.user;
      if (user != null) {
        // Update Firebase Authentication profile details
        await user.updateDisplayName(displayName);
        
        // Save structured UserProfile to Firestore
        final profile = UserProfile(
          uid: user.uid,
          email: email,
          displayName: displayName,
          homeCity: homeCity,
          createdAt: DateTime.now(),
        );
        await _firestoreService.saveUserProfile(profile);
      }

      developer.log("User signed up and profile saved: ${user?.uid}");
      return credentials;
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException in signUp: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      developer.log("Unknown error in signUp: $e");
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      developer.log("User logged out successfully.");
    } catch (e) {
      developer.log("Error in signOut: $e");
      rethrow;
    }
  }
}
