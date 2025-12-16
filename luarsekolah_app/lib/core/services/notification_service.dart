// lib/core/services/notification_service.dart

import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luarsekolah_app/features/todo/presentation/controllers/todo_controller.dart';
import 'package:firebase_core/firebase_core.dart';

/// Handler untuk background messages (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('[FCM Background] Message received: ${message.messageId}', name: 'NotificationService');
  developer.log('[FCM Background] Title: ${message.notification?.title}', name: 'NotificationService');
  developer.log('[FCM Background] Body: ${message.notification?.body}', name: 'NotificationService');
}

/// Top-level function untuk handle notification action saat app killed
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  developer.log('[Background Handler] Notification tapped in background!', name: 'NotificationService');
  developer.log('[Background Handler] Action: ${notificationResponse.actionId}', name: 'NotificationService');
  developer.log('[Background Handler] Payload: ${notificationResponse.payload}', name: 'NotificationService');

  try {
    await Firebase.initializeApp();
    developer.log('[Background Handler] ✅ Firebase initialized', name: 'NotificationService');
  } catch (e) {
    developer.log('[Background Handler] Firebase already initialized or error: $e', name: 'NotificationService', error: e);
  }

  if (notificationResponse.actionId == 'mark_complete') {
    await _handleMarkCompleteBackground(notificationResponse.payload);
  }
}

/// Helper function untuk mark complete di background
Future<void> _handleMarkCompleteBackground(String? payload) async {
  if (payload == null || payload.isEmpty) {
    developer.log('[Background Handler] Payload is null', name: 'NotificationService');
    return;
  }

  developer.log('[Background Handler] Processing mark complete: $payload', name: 'NotificationService');

  try {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    
    User? user = auth.currentUser;
    
    if (user == null) {
      developer.log('[Background Handler] No user logged in', name: 'NotificationService');
      return;
    }

    final userId = user.uid;

    final todoDoc = await firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(payload)
        .get();

    if (!todoDoc.exists) {
      developer.log('[Background Handler] Todo not found: $payload', name: 'NotificationService');
      return;
    }

    final currentCompleted = todoDoc.data()?['completed'] ?? false;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(payload)
        .update({
      'completed': !currentCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    developer.log('[Background Handler] ✅ Todo marked complete: $payload', name: 'NotificationService');

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifikasi untuk Todo App',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '✅ Todo Selesai!',
      'Todo berhasil ditandai selesai',
      notificationDetails,
    );
  } catch (e, stackTrace) {
    developer.log('[Background Handler] Error', name: 'NotificationService', error: e, stackTrace: stackTrace);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;
  static String? _pendingPayload;
  static String? _pendingAction;

  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[NotificationService] Already initialized', name: 'NotificationService');
      return;
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      await _requestPermission();
      await _initializeLocalNotifications();
      await _createNotificationChannels();
      await _getFCMToken();
      _setupFCMHandlers();

      _isInitialized = true;
      developer.log('[NotificationService] ✅ Initialized successfully', name: 'NotificationService');
    } catch (e, stackTrace) {
      developer.log('[NotificationService] ❌ Error initializing', name: 'NotificationService', error: e, stackTrace: stackTrace);
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('[NotificationService] Permission status: ${settings.authorizationStatus}', name: 'NotificationService');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('[NotificationService] ✅ User granted permission', name: 'NotificationService');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        developer.log('[NotificationService] ⚠️ User granted provisional permission', name: 'NotificationService');
      } else {
        developer.log('[NotificationService] ❌ User declined or has not accepted permission', name: 'NotificationService');
      }
    } catch (e) {
      developer.log('[NotificationService] Error requesting permission', name: 'NotificationService', error: e);
    }
  }

  /// Create notification channels (Android only)
  Future<void> _createNotificationChannels() async {
    try {
      const AndroidNotificationChannel todoChannel = AndroidNotificationChannel(
        'todo_channel',
        'Todo Notifications',
        description: 'Notifikasi untuk Todo App',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
        'todo_reminder_channel',
        'Todo Reminders',
        description: 'Reminder untuk Todo App',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(todoChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(reminderChannel);

      developer.log('[NotificationService] ✅ Notification channels created', name: 'NotificationService');
    } catch (e) {
      developer.log('[NotificationService] Error creating channels', name: 'NotificationService', error: e);
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTappedBackground,
    );

    developer.log('[NotificationService] Local notifications initialized', name: 'NotificationService');
  }

  @pragma('vm:entry-point')
  static void _onNotificationTappedBackground(NotificationResponse response) {
    developer.log('[NotificationService] Background notification tapped: ${response.payload}', name: 'NotificationService');
    developer.log('[NotificationService] Action: ${response.actionId}', name: 'NotificationService');

    if (response.payload != null && response.payload!.isNotEmpty) {
      _pendingPayload = response.payload;
      _pendingAction = response.actionId;
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      developer.log('''

╔═══════════════════════════════════════════════════════════╗
📱 FCM TOKEN (Copy untuk testing di Firebase Console):
╠═══════════════════════════════════════════════════════════╣
$_fcmToken
╚═══════════════════════════════════════════════════════════╝
''', name: 'NotificationService');

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        developer.log('[NotificationService] Token refreshed: $newToken', name: 'NotificationService');
      });
    } catch (e) {
      developer.log('[NotificationService] Error getting FCM token', name: 'NotificationService', error: e);
    }
  }

  /// Setup FCM message handlers
  void _setupFCMHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        developer.log('[NotificationService] App opened from terminated state', name: 'NotificationService');
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log('[FCM Foreground] Message received: ${message.messageId}', name: 'NotificationService');
    developer.log('[FCM Foreground] Title: ${message.notification?.title}', name: 'NotificationService');
    developer.log('[FCM Foreground] Body: ${message.notification?.body}', name: 'NotificationService');
    developer.log('[FCM Foreground] Data: ${message.data}', name: 'NotificationService');

    await showLocalNotification(
      title: message.notification?.title ?? 'Notifikasi',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    developer.log('[FCM Background Opened] Message: ${message.messageId}', name: 'NotificationService');
    developer.log('[FCM Background Opened] Data: ${message.data}', name: 'NotificationService');

    if (message.data.containsKey('todoId')) {
      final todoId = message.data['todoId'];
      _navigateToTodo(todoId);
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo Notifications',
        channelDescription: 'Notifikasi untuk Todo App',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      developer.log('[NotificationService] ✅ Local notification shown: $title', name: 'NotificationService');
    } catch (e) {
      developer.log('[NotificationService] Error showing notification', name: 'NotificationService', error: e);
    }
  }

  /// Schedule notification with custom time
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int? id,
  }) async {
    try {
      final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      developer.log('''

╔═══════════════════════════════════════════════════════════╗
⏰ SCHEDULING NOTIFICATION
╠═══════════════════════════════════════════════════════════╣
ID: $notificationId
Title: $title
Body: $body
Current Time: ${tz.TZDateTime.now(tz.local)}
Scheduled Time: $tzScheduledDate
Payload: $payload
╚═══════════════════════════════════════════════════════════╝
''', name: 'NotificationService');

      const androidDetails = AndroidNotificationDetails(
        'todo_reminder_channel',
        'Todo Reminders',
        channelDescription: 'Reminder untuk Todo App',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        ticker: 'Todo Reminder',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'mark_complete',
            '✅ Tandai Selesai',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time
      );

      developer.log('[NotificationService] ✅ Notification scheduled successfully!', name: 'NotificationService');
    } catch (e, stackTrace) {
      developer.log('[NotificationService] ❌ Error scheduling notification', name: 'NotificationService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    developer.log('[NotificationService] Notification $id cancelled', name: 'NotificationService');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
    developer.log('[NotificationService] All scheduled notifications cancelled', name: 'NotificationService');
  }

  /// Handle notification tap (foreground)
  void _onNotificationTapped(NotificationResponse response) {
    developer.log('''

╔═══════════════════════════════════════════════════════════╗
👆 NOTIFICATION TAPPED
╠═══════════════════════════════════════════════════════════╣
Action ID: ${response.actionId}
Payload: ${response.payload}
╚═══════════════════════════════════════════════════════════╝
''', name: 'NotificationService');

    if (response.actionId == 'mark_complete') {
      developer.log('[NotificationService] 🎯 Executing mark_complete action', name: 'NotificationService');
      _handleMarkComplete(response.payload);
    } else {
      if (response.payload != null && response.payload!.isNotEmpty) {
        _navigateToTodo(response.payload!);
      }
    }
  }

  /// Handle mark complete action
  Future<void> _handleMarkComplete(String? payload) async {
    if (payload == null || payload.isEmpty) {
      developer.log('[NotificationService] ❌ Payload is null or empty', name: 'NotificationService');
      return;
    }

    developer.log('[NotificationService] ✅ Processing mark complete: $payload', name: 'NotificationService');

    try {
      if (Get.isRegistered<TodoController>()) {
        final todoController = Get.find<TodoController>();
        await todoController.toggleComplete(payload);
        developer.log('[NotificationService] ✅ Completed via controller', name: 'NotificationService');
      } else {
        developer.log('[NotificationService] ⚠️ Controller not available, using direct Firestore', name: 'NotificationService');
        await _markTodoCompleteDirectly(payload);
      }

      await showLocalNotification(
        title: '✅ Todo Selesai!',
        body: 'Todo berhasil ditandai selesai',
      );
    } catch (e) {
      developer.log('[NotificationService] ❌ Error', name: 'NotificationService', error: e);

      await showLocalNotification(
        title: '❌ Error',
        body: 'Gagal menandai todo selesai',
      );
    }
  }

  /// Mark todo complete directly via Firestore
  Future<void> _markTodoCompleteDirectly(String todoId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        developer.log('[NotificationService] ❌ No user logged in', name: 'NotificationService');
        throw Exception('User not logged in');
      }

      final todoDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .get();

      if (!todoDoc.exists) {
        developer.log('[NotificationService] ❌ Todo not found: $todoId', name: 'NotificationService');
        throw Exception('Todo not found');
      }

      final currentCompleted = todoDoc.data()?['completed'] ?? false;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .update({
        'completed': !currentCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      developer.log('[NotificationService] ✅ Todo marked complete directly: $todoId', name: 'NotificationService');
    } catch (e) {
      developer.log('[NotificationService] ❌ Error in direct Firestore update', name: 'NotificationService', error: e);
      rethrow;
    }
  }

  /// Navigate to todo detail
  void _navigateToTodo(String todoId) {
    developer.log('[NotificationService] Navigating to todo: $todoId', name: 'NotificationService');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isRegistered<dynamic>()) {
        developer.log('[NotificationService] Navigate to todo: $todoId', name: 'NotificationService');
      }
    });
  }

  /// Check pending payload and process it
  void processPendingPayload() {
    if (_pendingPayload != null) {
      developer.log('[NotificationService] Processing pending payload: $_pendingPayload', name: 'NotificationService');
      developer.log('[NotificationService] Processing pending action: $_pendingAction', name: 'NotificationService');

      if (_pendingAction == 'mark_complete') {
        _handleMarkComplete(_pendingPayload);
      } else {
        _navigateToTodo(_pendingPayload!);
      }

      _pendingPayload = null;
      _pendingAction = null;
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    developer.log('[NotificationService] Pending notifications: ${pending.length}', name: 'NotificationService');
    for (var notif in pending) {
      developer.log('  - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}', name: 'NotificationService');
    }
    return pending;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('[NotificationService] Subscribed to topic: $topic', name: 'NotificationService');
    } catch (e) {
      developer.log('[NotificationService] Error subscribing to topic', name: 'NotificationService', error: e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('[NotificationService] Unsubscribed from topic: $topic', name: 'NotificationService');
    } catch (e) {
      developer.log('[NotificationService] Error unsubscribing from topic', name: 'NotificationService', error: e);
    }
  }
}