import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@pragma('pragma:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Register background message handler
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('PushNotificationService: Background handler registration failed: $e');
    }

    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for push notifications');
      
      // Get the token initially
      String? token = await _fcm.getToken();
      debugPrint('FCM Token: $token');
      await saveTokenToDatabase(token);

      // Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(newToken);
      });

      // Automatically upload token when authentication state changes
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _fcm.getToken().then((activeToken) {
            saveTokenToDatabase(activeToken);
          });
        }
      });

      // Handle incoming messages while app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
        }
      });

      // Handle message when app is in background but opened via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
      });

    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  // Upload FCM Token to current user's document in Firestore
  Future<void> saveTokenToDatabase(String? token) async {
    if (token == null || token.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenSync': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Fallback to set if update fails (e.g. document does not exist yet)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenSync': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }
}
