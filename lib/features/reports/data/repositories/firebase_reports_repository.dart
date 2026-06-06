import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/models/item_model.dart';
import '../../domain/repositories/reports_repository.dart';

class FirebaseReportsRepository implements ReportsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance for injection/usage
  static final FirebaseReportsRepository _instance = FirebaseReportsRepository._internal();
  factory FirebaseReportsRepository() => _instance;
  FirebaseReportsRepository._internal();

  @override
  Future<List<Item>> getItems() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .get();
      return _parseReportDocs(snapshot.docs);
    } catch (e) {
      debugPrint('FirebaseReportsRepository: Failed to fetch sorted items: $e');
      // In case of indexing errors in fresh firebase projects, fallback to unordered query
      try {
        final snapshot = await _firestore.collection('reports').get();
        return _parseReportDocs(snapshot.docs);
      } catch (err) {
        debugPrint('FirebaseReportsRepository: Failed fallback fetch: $err');
        rethrow;
      }
    }
  }

  List<Item> _parseReportDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final List<Item> items = [];
    for (var doc in docs) {
      try {
        items.add(Item.fromJson(doc.data(), doc.id));
      } catch (e) {
        debugPrint('FirebaseReportsRepository: Skipping malformed report document ${doc.id}: $e');
      }
    }
    return items;
  }

  @override
  Future<void> addReport(Item item) async {
    if (item.id.trim().isEmpty) {
      throw ArgumentError('Item ID cannot be empty');
    }
    try {
      final data = item.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['dateReported'] = FieldValue.serverTimestamp();
      await _firestore.collection('reports').doc(item.id).set(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await _firestore.collection('reports').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateReport(Item item) async {
    if (item.id.trim().isEmpty) {
      throw ArgumentError('Item ID cannot be empty');
    }
    try {
      final data = item.toJson();
      data.remove('createdAt');
      data.remove('dateReported');
      data.remove('createdBy');
      data.remove('userId');
      
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('reports').doc(item.id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateItemStatus(String id, String status) async {
    try {
      await _firestore.collection('reports').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
