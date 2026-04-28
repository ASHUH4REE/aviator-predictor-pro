import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background handler MUST be a top-level function for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Process background messages here (analytics, persistence, etc.).
  if (kDebugMode) {
    debugPrint('BG message: ${message.messageId}');
  }
}

/// Centralised FCM bootstrap. Call `initialize()` from `main()` after Firebase.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? token;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    token = await _fcm.getToken();
    if (kDebugMode) debugPrint('FCM token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (kDebugMode) {
        debugPrint('Foreground push: ${msg.notification?.title}');
      }
    });

    // Subscribe to broadcast topic so admin notifications reach everyone.
    await _fcm.subscribeToTopic('all_users');
  }
}
