import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotif =
  FlutterLocalNotificationsPlugin();

  // 🔐 Permission + Token - FIXED VERSION
  static Future<void> initFCM() async {
    try {
      // Request permission first
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("🔔 Permission status: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {

        if (Platform.isIOS) {
          // Wait for APNS token with timeout
          String? apnsToken = await _fcm.getAPNSToken();

          if (apnsToken != null) {
            print("✅ APNS Token received: $apnsToken");

            // Now safe to get FCM token
            String? token = await _fcm.getToken();
            print("🔥 FCM TOKEN = $token");
          } else {
            print("⚠️ APNS token not available immediately, setting up listener...");

            // Listen for token refresh when APNS becomes available
            _fcm.onTokenRefresh.listen((newToken) {
              print("🔥 FCM TOKEN (refreshed) = $newToken");
              // TODO: Save token to your backend here
            });

            // Try to get token anyway (might work after a delay)
            Future.delayed(Duration(seconds: 2), () async {
              try {
                String? token = await _fcm.getToken();
                if (token != null) {
                  print("🔥 FCM TOKEN (delayed) = $token");
                }
              } catch (e) {
                print("⚠️ Could not get FCM token after delay: $e");
              }
            });
          }
        } else {
          // Android - direct token retrieval
          String? token = await _fcm.getToken();
          print("🔥 FCM TOKEN = $token");
        }
      } else {
        print("❌ Notification permission denied");
      }
    } catch (e, stackTrace) {
      print("❌ FCM Init Error: $e");
      print("Stack trace: $stackTrace");
      // Don't crash the app - continue execution
    }
  }

  // 🔔 Local notification setup
  static Future<void> setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings =
      InitializationSettings(android: android, iOS: ios);

      await _localNotif.initialize(settings);
      print("✅ Local notifications initialized");
    } catch (e) {
      print("❌ Local notification setup error: $e");
    }
  }

  // 📩 Foreground push
  static void listenForeground() {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📬 Received foreground message: ${message.notification?.title}");

        if (message.notification != null) {
          _localNotif.show(
            message.hashCode, // Use unique ID for each notification
            message.notification!.title,
            message.notification!.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'school_scout',
                'School Scout',
                channelDescription: 'School Scout notifications',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      });
      print("✅ Foreground message listener set up");
    } catch (e) {
      print("❌ Foreground listener error: $e");
    }
  }

  static Future<void> requestAndroidPermission() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.notification.request();
        print("🔔 Android notification permission: $status");
      } catch (e) {
        print("❌ Android permission error: $e");
      }
    }
  }

  static Future<void> requestPermissionOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      bool alreadyAsked = prefs.getBool('notif_permission_asked') ?? false;
      if (alreadyAsked) {
        print("ℹ️ Permission already asked before");
        return; // ❌ Do not show again
      }

      // iOS permission
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Android 13+ permission
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      await prefs.setBool('notif_permission_asked', true);
      print("✅ Permission request completed");
    } catch (e) {
      print("❌ Permission request error: $e");
    }
  }

  // 🚀 Initialize everything in the right order
  static Future<void> initializeAll() async {
    try {
      print("🚀 Starting push service initialization...");

      await setupLocalNotifications();
      await initFCM();
      listenForeground();

      print("✅ Push service fully initialized");
    } catch (e) {
      print("❌ Push service initialization error: $e");
    }
  }
}