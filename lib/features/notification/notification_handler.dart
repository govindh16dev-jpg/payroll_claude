import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../../service/api_service.dart';
import '../../service/app_expection.dart';

class NotificationService extends ApiProvider{
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel _channel;

  // FCM Token management constants
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastTokenUpdateKey = 'last_token_update';
  static const int _tokenUpdateIntervalDays = 2;

  Future<void> init() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDDiP35QpJwsMwvBUXYeUMQxrBtZfD0efE",
            authDomain: "azatecon-3b631.firebaseapp.com",
            projectId: "azatecon-3b631",
            storageBucket: "azatecon-3b631.firebasestorage.app",
            messagingSenderId: "543784324609",
            appId: "1:543784324609:web:db3c12da5c9e23cfd03a00"
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    await requestNotificationPermission();
    await _initLocalNotifications();
    // Removed token handling from init - will be called from home page
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('ℹ️ User granted provisional permission');
    } else {
      print('❌ User declined or has not accepted permission');
    }
  }

  AndroidNotificationChannel emergencyChannel = const AndroidNotificationChannel(
    'emergency_channel',
    'Emergency Alerts',
    description: 'This channel is for critical/emergency notifications.',
    importance: Importance.max,
    playSound: true,
    enableLights: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('emergency_tone'),
  );

  Future<void> _initLocalNotifications() async {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important messages',
      importance: Importance.high,
      playSound: true, // Added playSound for Android
    );

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS settings with proper permissions
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Combined settings for all platforms
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Create emergency channel first
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);

    // Initialize the plugin with all platform settings
    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          // _handleNotificationTap("","");
        }
      },
    );

    // Create regular channel
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // **CRUCIAL: Request iOS permissions explicitly after initialization**
    final bool? result = await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    print('iOS Permissions granted: $result');
  }

  // **CALL THIS METHOD FROM HOME PAGE AFTER AUTHENTICATION**
  Future<void> initializeTokenHandlingForAuthenticatedUser() async {
    try {
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token refreshed: $newToken');
        await _updateFCMToken(newToken, forceUpdate: true);
      });

      // Handle initial token update
      await handleTokenUpdate();

      print('✅ Token handling initialized for authenticated user');
    } catch (e) {
      print('❌ Error initializing token handling: $e');
    }
  }

  // **CALL THIS METHOD FROM HOME PAGE TO CHECK AND UPDATE TOKEN**
  Future<void> handleTokenUpdate() async {
    try {
      String? currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken != null) {
        print('🔥 FCM Token: $currentToken');
        await _updateFCMToken(currentToken);
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error handling token update: $e');
    }
  }

  // Update FCM token with API call and secure storage
  Future<void> _updateFCMToken(String newToken, {bool forceUpdate = false}) async {
    try {
      const _secureStorage = FlutterSecureStorage();

      final storedToken = await _secureStorage.read(key: _fcmTokenKey);
      final lastUpdateStr = await _secureStorage.read(key: _lastTokenUpdateKey);

      bool shouldUpdate = forceUpdate;

      if (!shouldUpdate) {
        // Check if token is different
        if (storedToken != newToken) {
          shouldUpdate = true;
        } else if (lastUpdateStr != null) {
          // Check if 2 days have passed since last update
          final lastUpdate = DateTime.tryParse(lastUpdateStr);
          if (lastUpdate != null) {
            final daysSinceUpdate = DateTime.now().difference(lastUpdate).inDays;
            shouldUpdate = daysSinceUpdate >= _tokenUpdateIntervalDays;
          }
        } else {
          // No previous update record
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        // Call API to update token
        final success = await _sendTokenToServer(newToken);

        if (success) {
          // Store token and update timestamp securely
          await _secureStorage.write(key: _fcmTokenKey, value: newToken);
          await _secureStorage.write(key: _lastTokenUpdateKey, value: DateTime.now().toIso8601String());
          print('✅ FCM Token updated successfully');
        } else {
          print('❌ Failed to update FCM token on server');
        }
      } else {
        print('ℹ️ FCM Token update not needed');
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
    }
  }

  // Send FCM token to server
  Future<bool> _sendTokenToServer(String token) async {
    try {
      final response = await _updateFCMTokenAPI(token);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error sending token to server: $e');
      return false;
    }
  }

  // API call to update FCM token
  Future<http.Response> _updateFCMTokenAPI(String fcmToken) async {
    http.Response response;
    try {
      response = await  updateToken(
          ApiConstants.updateFCMToken,
          headers: null,
          body: {
            "fcm_token": fcmToken
          }
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("FCM Token update error: $e $s");
      rethrow;
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    NotificationService()._showLocalNotification(message);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      if (notification.android?.channelId == 'emergency_channel') {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              notification.android!.channelId!,
              'Emergency Alerts',
              channelDescription: emergencyChannel.description,
              icon: '@mipmap/launcher_icon',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            // **FIXED: Added iOS configuration with sound**
            iOS: const DarwinNotificationDetails(
              presentSound: true,
              presentAlert: true,
              presentBadge: true,
              sound: 'default', // or your custom sound file name
            ),
          ),
          payload: jsonEncode(message.data),
        );
      } else {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/launcher_icon',
              playSound: true, // **Added playSound for Android**
            ),
            // **FIXED: Added iOS configuration with sound**
            iOS: const DarwinNotificationDetails(
              presentSound: true,
              presentAlert: true,
              presentBadge: true,
              sound: 'default', // or your custom sound file name
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    }
  }

  // Get token without updating (safe to call anytime)
  Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> handleForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      print('${message.notification?.body}');
      print('${message.notification?.android?.channelId}');
      print('${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      print('$title $body');
      // _handleNotificationTap(title,body);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      // if (message != null) {
      //   _handleNotificationTap("","");
      // }
    });
  }

  // Public method to manually force token update (requires authentication)
  Future<void> forceTokenUpdate() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _updateFCMToken(token, forceUpdate: true);
      }
    } catch (e) {
      print('❌ Error forcing token update: $e');
    }
  }

  // Get stored FCM token from secure storage
  Future<String?> getStoredToken() async {
    const _secureStorage = FlutterSecureStorage();
    try {
      return await _secureStorage.read(key: _fcmTokenKey);
    } catch (e) {
      print('❌ Error reading stored token: $e');
      return null;
    }
  }

  // Clear stored FCM data (useful for logout)
  Future<void> clearStoredTokenData() async {
    const _secureStorage = FlutterSecureStorage();
    try {
      await _secureStorage.delete(key: _fcmTokenKey);
      await _secureStorage.delete(key: _lastTokenUpdateKey);
      print('✅ FCM token data cleared from secure storage');
    } catch (e) {
      print('❌ Error clearing token data: $e');
    }
  }

  // Get last token update timestamp
  Future<DateTime?> getLastTokenUpdate() async {
    const _secureStorage = FlutterSecureStorage();
    try {
      final lastUpdateStr = await _secureStorage.read(key: _lastTokenUpdateKey);
      return lastUpdateStr != null ? DateTime.tryParse(lastUpdateStr) : null;
    } catch (e) {
      print('❌ Error reading last update timestamp: $e');
      return null;
    }
  }

// void _handleNotificationTap(title,body) {
//   navigatorKey.currentState?.push(
//     MaterialPageRoute(
//       builder: (_) => NotificationPage(
//         title: title ?? 'No Title',
//         body:body ?? 'No Body',
//       ),
//     ),
//   );
// }
}
