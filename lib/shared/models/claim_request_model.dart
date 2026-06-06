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
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
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
