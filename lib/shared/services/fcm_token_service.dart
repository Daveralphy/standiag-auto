// FCM token registration — lets a mechanic's device actually receive the
// push alert a Cloud Function sends when a car owner broadcasts a nearby
// service request (see functions/index.js, notifyNearbyMechanics). Requests
// notification permission, saves the device's token onto the mechanic's
// Firestore doc, and keeps it fresh if it ever rotates.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> registerMechanicFcmToken(String mechanicId) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) {
      await _saveToken(mechanicId, token);
    }
    messaging.onTokenRefresh.listen((newToken) => _saveToken(mechanicId, newToken));
  } catch (e) {
    if (kDebugMode) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}

Future<void> _saveToken(String mechanicId, String token) async {
  await FirebaseFirestore.instance
      .collection('mechanics')
      .doc(mechanicId)
      .update({'fcmToken': token});
}

/// Handles a push arriving while the app is fully backgrounded or
/// terminated. Must be a top-level function, not a method or closure — that
/// requirement comes from FlutterFire, which invokes it in its own isolate.
/// Currently a no-op: the OS already shows the notification itself from the
/// message's `notification` payload, so there's nothing custom to do yet —
/// registering the handler is still required boilerplate for FCM to
/// initialize correctly on Android.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
