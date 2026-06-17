import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/models/alert_model.dart';

class FirebaseAlertsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final FirebaseAlertsRepository _instance = FirebaseAlertsRepository._internal();
  factory FirebaseAlertsRepository() => _instance;
  FirebaseAlertsRepository._internal();

  // Streams active alerts for a specific user
  Stream<List<Alert>> streamUserAlerts(String uid) {
    return _firestore
        .collection('alerts')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final List<Alert> alerts = [];
      for (var doc in snapshot.docs) {
        try {
          alerts.add(Alert.fromJson(doc.data(), doc.id));
        } catch (e) {
          debugPrint('FirebaseAlertsRepository: Skipping malformed alert document ${doc.id}: $e');
        }
      }
      return alerts;
    });
  }

  // Fallback future if needed
  Future<List<Alert>> getUserAlerts(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('createdBy', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      final List<Alert> alerts = [];
      for (var doc in snapshot.docs) {
        try {
          alerts.add(Alert.fromJson(doc.data(), doc.id));
        } catch (e) {
          debugPrint('FirebaseAlertsRepository: Skipping malformed alert: $e');
        }
      }
      return alerts;
    } catch (e) {
      debugPrint('FirebaseAlertsRepository: Failed ordered query: $e. Falling back.');
      // Fallback query without orderBy to avoid index errors in dev
      final snapshot = await _firestore
          .collection('alerts')
          .where('createdBy', isEqualTo: uid)
          .get();
      
      final List<Alert> alerts = [];
      for (var doc in snapshot.docs) {
        try {
          alerts.add(Alert.fromJson(doc.data(), doc.id));
        } catch (e) {
          debugPrint('FirebaseAlertsRepository: Skipping malformed alert: $e');
        }
      }
      // Sort in memory
      alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return alerts;
    }
  }

  // Create/save a new alert subscription
  Future<void> addAlert(Alert alert) async {
    try {
      final data = alert.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      
      // If document ID is empty, let Firestore generate one
      if (alert.id.trim().isEmpty) {
        await _firestore.collection('alerts').add(data);
      } else {
        await _firestore.collection('alerts').doc(alert.id).set(data);
      }
    } catch (e) {
      debugPrint('FirebaseAlertsRepository: Error adding alert: $e');
      rethrow;
    }
  }

  // Delete an alert subscription
  Future<void> deleteAlert(String id) async {
    try {
      await _firestore.collection('alerts').doc(id).delete();
    } catch (e) {
      debugPrint('FirebaseAlertsRepository: Error deleting alert: $e');
      rethrow;
    }
  }
}
