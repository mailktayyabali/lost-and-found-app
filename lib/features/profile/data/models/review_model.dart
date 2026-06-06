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
    final revieweeUid = json['revieweeUid'] as String?;
    final reviewerUid = json['reviewerUid'] as String?;
    
    if (revieweeUid == null || revieweeUid.isEmpty) {
      throw const FormatException('revieweeUid must not be null or empty');
    }
    if (reviewerUid == null || reviewerUid.isEmpty) {
      throw const FormatException('reviewerUid must not be null or empty');
    }

    final ratingVal = json['rating'];
    if (ratingVal == null) {
      throw const FormatException('Review rating is missing');
    }
    
    final int rawRating = (ratingVal as num).toInt();
    int rating = rawRating;
    if (rating < 1) {
      rating = 1;
    } else if (rating > 5) {
      rating = 5;
    }

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
      revieweeUid: revieweeUid,
      reviewerUid: reviewerUid,
      reviewerName: json['reviewerName'] ?? 'Anonymous',
      reviewerAvatarUrl: json['reviewerAvatarUrl'] ?? '',
      rating: rating,
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
