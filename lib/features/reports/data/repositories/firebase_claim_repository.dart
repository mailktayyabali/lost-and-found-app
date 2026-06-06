import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/claim_request_model.dart';
import '../../domain/repositories/claim_repository.dart';

class FirebaseClaimRepository implements ClaimRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final FirebaseClaimRepository _instance = FirebaseClaimRepository._internal();
  factory FirebaseClaimRepository() => _instance;
  FirebaseClaimRepository._internal();

  @override
  Future<void> submitClaimRequest(ClaimRequest request) async {
    try {
      final docRef = _firestore.collection('claim_requests').doc();
      final data = request.toJson();
      await docRef.set(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ClaimRequest>> getIncomingRequests(String ownerUid) async {
    try {
      final snapshot = await _firestore
          .collection('claim_requests')
          .where('ownerUid', isEqualTo: ownerUid)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ClaimRequest.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // If ordering fails because of missing composite index, fallback to sorting in memory
      try {
        final fallbackSnapshot = await _firestore
            .collection('claim_requests')
            .where('ownerUid', isEqualTo: ownerUid)
            .get();
        final list = fallbackSnapshot.docs
            .map((doc) => ClaimRequest.fromJson(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (err) {
        rethrow;
      }
    }
  }

  @override
  Future<ClaimRequest?> getPendingRequestForItem(String itemId) async {
    try {
      final snapshot = await _firestore
          .collection('claim_requests')
          .where('itemId', isEqualTo: itemId)
          .where('status', isEqualTo: 'PENDING')
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return ClaimRequest.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> approveClaimRequest(String requestId, String itemId) async {
    try {
      final batch = _firestore.batch();

      final requestRef = _firestore.collection('claim_requests').doc(requestId);
      batch.update(requestRef, {'status': 'APPROVED'});

      final itemRef = _firestore.collection('reports').doc(itemId);
      batch.update(itemRef, {
        'status': 'RESOLVED',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also reject all other pending requests for the same item (if any exist)
      final otherPending = await _firestore
          .collection('claim_requests')
          .where('itemId', isEqualTo: itemId)
          .where('status', isEqualTo: 'PENDING')
          .get();

      for (var doc in otherPending.docs) {
        if (doc.id != requestId) {
          batch.update(doc.reference, {'status': 'REJECTED'});
        }
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectClaimRequest(String requestId) async {
    try {
      await _firestore.collection('claim_requests').doc(requestId).update({
        'status': 'REJECTED',
      });
    } catch (e) {
      rethrow;
    }
  }
}
