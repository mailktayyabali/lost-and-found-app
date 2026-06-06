import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String revieweeUid; // UID of the user being reviewed
  final String reviewerUid; // UID of the user who wrote the review
  final String reviewerName; // Name of the reviewer
  final String reviewerAvatarUrl; // Avatar of the reviewer
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.revieweeUid,
    required this.reviewerUid,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parsedDate;
    final timestamp = json['createdAt'];
    if (timestamp is Timestamp) {
      parsedDate = timestamp.toDate();
    } else if (timestamp is String) {
      parsedDate = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Review(
      id: docId,
      revieweeUid: json['revieweeUid'] ?? '',
      reviewerUid: json['reviewerUid'] ?? '',
      reviewerName: json['reviewerName'] ?? 'Anonymous',
      reviewerAvatarUrl: json['reviewerAvatarUrl'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revieweeUid': revieweeUid,
      'reviewerUid': reviewerUid,
      'reviewerName': reviewerName,
      'reviewerAvatarUrl': reviewerAvatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
