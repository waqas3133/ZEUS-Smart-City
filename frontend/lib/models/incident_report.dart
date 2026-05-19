import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentReport {
  final String id;
  final String reporterId;
  final String detectedEvent;
  final String severity;
  final double latitude;
  final double longitude;
  final String city;
  final String area;
  final String aiSummary;
  final List<String> detectedObjects;
  final List<String> recommendedActions;
  final String imageUrl;
  final DateTime createdAt;

  IncidentReport({
    required this.id,
    required this.reporterId,
    required this.detectedEvent,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.area,
    required this.aiSummary,
    required this.detectedObjects,
    required this.recommendedActions,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporter_id': reporterId,
      'detectedEvent': detectedEvent,
      'detected_event': detectedEvent,
      'severity': severity,
      'risk_level': severity,
      'latitude': latitude,
      'longitude': longitude,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'area': area,
      },
      'city': city,
      'area': area,
      'aiSummary': aiSummary,
      'ai_summary': aiSummary,
      'detectedObjects': detectedObjects,
      'detected_objects': detectedObjects,
      'recommendedActions': recommendedActions,
      'recommended_actions': recommendedActions,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'created_at': Timestamp.fromDate(createdAt),
      'status': 'active',
    };
  }

  factory IncidentReport.fromMap(Map<String, dynamic> map, String docId) {
    final locationMap = map['location'] as Map<String, dynamic>?;
    return IncidentReport(
      id: docId,
      reporterId: map['reporterId'] ?? map['reporter_id'] ?? '',
      detectedEvent: map['detectedEvent'] ?? map['detected_event'] ?? 'General Incident',
      severity: map['severity'] ?? map['risk_level'] ?? 'LOW',
      latitude: (map['latitude'] as num?)?.toDouble() ?? (locationMap?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? (locationMap?['longitude'] as num?)?.toDouble() ?? 0.0,
      city: map['city'] ?? locationMap?['city'] ?? '',
      area: map['area'] ?? locationMap?['area'] ?? '',
      aiSummary: map['aiSummary'] ?? map['ai_summary'] ?? '',
      detectedObjects: List<String>.from(map['detectedObjects'] ?? map['detected_objects'] ?? []),
      recommendedActions: List<String>.from(map['recommendedActions'] ?? map['recommended_actions'] ?? []),
      imageUrl: map['imageUrl'] ?? map['image_url'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory IncidentReport.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentReport.fromMap(data, doc.id);
  }
}
