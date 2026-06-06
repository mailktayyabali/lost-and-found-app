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
      // Fallback: query strictly by itemId and filter in-memory
      try {
        final fallbackSnapshot = await _firestore
            .collection('claim_requests')
            .where('itemId', isEqualTo: itemId)
            .get();
        final pendingDocs = fallbackSnapshot.docs.where((doc) => doc.data()['status'] == 'PENDING');
        if (pendingDocs.isEmpty) return null;
        return ClaimRequest.fromJson(pendingDocs.first.data(), pendingDocs.first.id);
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<void> approveClaimRequest(String requestId, String itemId) async {
    try {
      // Get other pending requests first (with fallback)
      List<DocumentSnapshot> otherPendingDocs = [];
      try {
        final otherPending = await _firestore
            .collection('claim_requests')
            .where('itemId', isEqualTo: itemId)
            .where('status', isEqualTo: 'PENDING')
            .get();
        otherPendingDocs = otherPending.docs;
      } catch (_) {
        final fallbackPending = await _firestore
            .collection('claim_requests')
            .where('itemId', isEqualTo: itemId)
            .get();
        otherPendingDocs = fallbackPending.docs
            .where((doc) => doc.data()['status'] == 'PENDING')
            .toList();
      }

      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('claim_requests').doc(requestId);
        final itemRef = _firestore.collection('reports').doc(itemId);

        final requestDoc = await transaction.get(requestRef);
        final itemDoc = await transaction.get(itemRef);

        if (!itemDoc.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Report item does not exist.',
          );
        }
        if (!requestDoc.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Claim request does not exist.',
          );
        }

        final itemData = itemDoc.data()!;
        if (itemData['status'] == 'RESOLVED') {
          throw StateError('This item has already been resolved.');
        }

        // Perform updates atomically
        transaction.update(requestRef, {'status': 'APPROVED'});
        transaction.update(itemRef, {
          'status': 'RESOLVED',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        for (var doc in otherPendingDocs) {
          if (doc.id != requestId) {
            transaction.update(doc.reference, {'status': 'REJECTED'});
          }
        }
      });
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
