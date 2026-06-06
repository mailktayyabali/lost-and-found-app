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
      return snapshot.docs.map((doc) => Review.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      // Fallback to client-side sorting in case of Firestore indexing delay
      try {
        final snapshot = await _firestore
            .collection('reviews')
            .where('revieweeUid', isEqualTo: revieweeUid)
            .get();
        final reviews = snapshot.docs.map((doc) => Review.fromJson(doc.data(), doc.id)).toList();
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return reviews;
      } catch (err) {
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
