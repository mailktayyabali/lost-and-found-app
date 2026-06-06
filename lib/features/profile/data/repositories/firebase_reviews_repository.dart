import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class FirebaseReviewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseReviewsRepository _instance = FirebaseReviewsRepository._internal();
  factory FirebaseReviewsRepository() => _instance;
  FirebaseReviewsRepository._internal();

  // Fetch reviews for a specific user (revieweeUid)
  Future<List<Review>> getReviews(String revieweeUid) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('revieweeUid', isEqualTo: revieweeUid)
          .orderBy('createdAt', descending: true)
          .get();
      // Guard snapshot.docs mapping by filtering/checking doc.data() to ensure Review.fromJson is not called with null
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data != null ? Review.fromJson(data, doc.id) : null;
          })
          .whereType<Review>()
          .toList();
    } on FirebaseException catch (e) {
      final isIndexError = e.code == 'failed-precondition' ||
          (e.message != null && e.message!.contains('requires an index'));
      if (isIndexError) {
        // Fallback to client-side sorting in case of Firestore indexing delay
        try {
          final snapshot = await _firestore
              .collection('reviews')
              .where('revieweeUid', isEqualTo: revieweeUid)
              .get();
          // Guard snapshot.docs mapping by filtering/checking doc.data() to ensure Review.fromJson is not called with null
          final reviews = snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                return data != null ? Review.fromJson(data, doc.id) : null;
              })
              .whereType<Review>()
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        } catch (err) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  // Add a new review
  Future<void> addReview(Review review) async {
    try {
      await _firestore.collection('reviews').add(review.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
