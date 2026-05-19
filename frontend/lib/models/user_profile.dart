import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String homeCity;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.homeCity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'homeCity': homeCity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      homeCity: map['homeCity'] ?? 'Karachi',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }
}
