import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String requesterUid;
  final String requesterName;
  final String ownerUid;
  final String description;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime createdAt;

  ClaimRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.requesterUid,
    required this.requesterName,
    required this.ownerUid,
    required this.description,
    this.status = 'PENDING',
    required this.createdAt,
  });

  factory ClaimRequest.fromJson(Map<String, dynamic> json, String docId) {
    return ClaimRequest(
      id: docId,
      itemId: json['itemId'] ?? '',
      itemTitle: json['itemTitle'] ?? '',
      itemImageUrl: json['itemImageUrl'] ?? '',
      requesterUid: json['requesterUid'] ?? '',
      requesterName: json['requesterName'] ?? '',
      ownerUid: json['ownerUid'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: () {
        final raw = json['createdAt'];
        if (raw == null) {
          throw FormatException('Missing required field "createdAt" in ClaimRequest JSON');
        }
        if (raw is Timestamp) {
          return raw.toDate();
        }
        if (raw is String) {
          final parsed = DateTime.tryParse(raw);
          if (parsed != null) return parsed;
        }
        throw FormatException('Invalid or unparsable "createdAt" field in ClaimRequest JSON: $raw');
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemImageUrl': itemImageUrl,
      'requesterUid': requesterUid,
      'requesterName': requesterName,
      'ownerUid': ownerUid,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
