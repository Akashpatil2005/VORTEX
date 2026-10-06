import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this AFTER login
  Future<void> initFCM() async {
    await _requestPermission();
    await _saveTokenToFirestore();
    _listenForegroundMessages();
    _listenBackgroundTap();
  }

  // 🔐 Ask notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log("FCM Permission: ${settings.authorizationStatus}");
  }

  // 🔑 Get token & store in Firestore
  Future<void> _saveTokenToFirestore() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String? token = await _messaging.getToken();
    if (token == null) return;

    log("FCM TOKEN: $token");

    await _firestore.collection('users').doc(user.uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 🔄 Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': newToken,
      });
    });
  }

  // 📲 Foreground notifications
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("FOREGROUND NOTIFICATION RECEIVED");

      log("Title: ${message.notification?.title}");
      log("Body: ${message.notification?.body}");
      log("Data: ${message.data}");

      // 👉 Later you will:
      // showDialog / play siren / vibration / alert UI
    });
  }

  // 📬 Background & terminated notification tap
  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("NOTIFICATION CLICKED");

      log("Data Payload: ${message.data}");

      // 👉 Later:
      // navigate to Alert Screen
      // use message.data['alertType'], missionId, robotId
    });
  }
}
