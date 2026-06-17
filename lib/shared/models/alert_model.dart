import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String name;
  final String keywords;
  final String category;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isLostAlert;
  final String createdBy;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.name,
    required this.keywords,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isLostAlert,
    required this.createdBy,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json, String docId) {
    return Alert(
      id: docId,
      name: json['name'] ?? '',
      keywords: json['keywords'] ?? '',
      category: json['category'] ?? 'Other',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : 0.0,
      radius: json['radius'] != null ? (json['radius'] as num).toDouble() : 5.0,
      isLostAlert: json['isLostAlert'] ?? true,
      createdBy: json['createdBy'] ?? '',
      createdAt: () {
        final raw = json['createdAt'];
        if (raw == null) return DateTime.now();
        if (raw is Timestamp) return raw.toDate();
        if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
        return DateTime.now();
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'keywords': keywords,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isLostAlert': isLostAlert,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
