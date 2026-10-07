import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/constants.dart';
import 'user_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final UserService _userService = UserService();

  bool _isInitialized = false;

  /// Initialize Firebase Messaging & Flutter Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Request Push Notification permissions
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // 2. Initialize Android & iOS local notification settings (skipped on web)
      if (!kIsWeb) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

        const InitializationSettings initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            debugPrint('Notification clicked: ${response.payload}');
          },
        );

        // 3. Create high importance Android notification channel
        if (defaultTargetPlatform == TargetPlatform.android) {
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            description: AppConstants.notificationChannelDesc,
            importance: Importance.high,
            playSound: true,
          );

          await _localNotifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(channel);
        }
      }

      // 4. Set Background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Handle Foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.notification?.title}');
        showLocalNotification(
          title: message.notification?.title ?? AppConstants.appName,
          body: message.notification?.body ?? 'New message received',
          payload: message.data['chatId'],
        );
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init exception: $e');
    }
  }

  /// Retrieve FCM token and persist it to user document in Firestore
  Future<String?> getAndSaveToken(String currentUserId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _userService.updateFcmToken(uid: currentUserId, token: token);
        debugPrint('FCM Token successfully registered: $token');
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _userService.updateFcmToken(uid: currentUserId, token: newToken);
      });

      return token;
    } catch (e) {
      debugPrint('Failed to retrieve FCM token: $e');
      return null;
    }
  }

  /// Show a local head-up notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
