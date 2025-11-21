// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/todo/presentation/controllers/todo_controller.dart';
import 'package:firebase_core/firebase_core.dart';


/// Handler untuk background messages (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM Background] Message received: ${message.messageId}');
  print('[FCM Background] Title: ${message.notification?.title}');
  print('[FCM Background] Body: ${message.notification?.body}');
}

// Top-level function untuk handle notification action saat app killed
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  print('[Background Handler] Notification tapped in background!');
  print('[Background Handler] Action: ${notificationResponse.actionId}');
  print('[Background Handler] Payload: ${notificationResponse.payload}');

  // Initialize Firebase jika belum
  try {
    await Firebase.initializeApp();
    print('[Background Handler] ✅ Firebase initialized');
  } catch (e) {
    print('[Background Handler] Firebase already initialized or error: $e');
  }

  // Handle actions
  if (notificationResponse.actionId == 'mark_complete') {
    await _handleMarkCompleteBackground(notificationResponse.payload);
  } else if (notificationResponse.actionId == 'snooze') {
    await _handleSnoozeBackground(notificationResponse.payload);
  }
}

// Helper function untuk mark complete di background
Future<void> _handleMarkCompleteBackground(String? payload) async {
  if (payload == null || payload.isEmpty) {
    print('[Background Handler] Payload is null');
    return;
  }

  print('[Background Handler] Processing mark complete: $payload');

  try {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    
    // Get current user
    User? user = auth.currentUser;
    
    if (user == null) {
      print('[Background Handler] No user logged in');
      return;
    }

    final userId = user.uid;

    // Get todo document
    final todoDoc = await firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(payload)
        .get();

    if (!todoDoc.exists) {
      print('[Background Handler] Todo not found: $payload');
      return;
    }

    final currentCompleted = todoDoc.data()?['completed'] ?? false;

    // Toggle completed status
    await firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(payload)
        .update({
      'completed': !currentCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('[Background Handler] ✅ Todo marked complete: $payload');

    // Show notification feedback
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
    print('[Background Handler] Error: $e');
    print('[Background Handler] StackTrace: $stackTrace');
  }
}

// Helper function untuk snooze di background
Future<void> _handleSnoozeBackground(String? payload) async {
  if (payload == null || payload.isEmpty) {
    print('[Background Handler] Snooze payload is null');
    return;
  }

  print('[Background Handler] Processing snooze: $payload');

  try {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'todo_reminder_channel',
      'Todo Reminders',
      channelDescription: 'Reminder untuk Todo App',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'mark_complete',
          '✅ Tandai Selesai',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze',
          '⏰ Ingatkan 10 detik lagi',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⏰ Reminder: Todo',
      'Jangan lupa selesaikan todo ini!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    print('[Background Handler] ✅ Snooze scheduled successfully');

    // Show immediate feedback
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      '⏰ Reminder Ditunda',
      'Kamu akan diingatkan lagi dalam 10 detik',
      notificationDetails,
    );
  } catch (e, stackTrace) {
    print('[Background Handler] Error snoozing: $e');
    print('[Background Handler] StackTrace: $stackTrace');
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
      print('[NotificationService] Already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Create notification channels
      await _createNotificationChannels();

      // Get FCM token
      await _getFCMToken();

      // Setup FCM handlers
      _setupFCMHandlers();

      _isInitialized = true;
      print('[NotificationService] ✅ Initialized successfully');
    } catch (e, stackTrace) {
      print('[NotificationService] ❌ Error initializing: $e');
      print('[NotificationService] StackTrace: $stackTrace');
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

      print(
          '[NotificationService] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[NotificationService] ✅ User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('[NotificationService] ⚠️ User granted provisional permission');
      } else {
        print(
            '[NotificationService] ❌ User declined or has not accepted permission');
      }
    } catch (e) {
      print('[NotificationService] Error requesting permission: $e');
    }
  }

  /// Create notification channels (Android only)
  Future<void> _createNotificationChannels() async {
    try {
      // Channel untuk notifikasi biasa
      const AndroidNotificationChannel todoChannel = AndroidNotificationChannel(
        'todo_channel',
        'Todo Notifications',
        description: 'Notifikasi untuk Todo App',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Channel untuk reminder
      const AndroidNotificationChannel reminderChannel =
          AndroidNotificationChannel(
        'todo_reminder_channel',
        'Todo Reminders',
        description: 'Reminder untuk Todo App',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(todoChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(reminderChannel);

      print('[NotificationService] ✅ Notification channels created');
    } catch (e) {
      print('[NotificationService] Error creating channels: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveBackgroundNotificationResponse:
          _onNotificationTappedBackground,
    );

    print('[NotificationService] Local notifications initialized');
  }

  /// Background notification tap handler (must be top-level or static)
  @pragma('vm:entry-point')
  static void _onNotificationTappedBackground(NotificationResponse response) {
    print(
        '[NotificationService] Background notification tapped: ${response.payload}');
    print('[NotificationService] Action: ${response.actionId}');

    if (response.payload != null && response.payload!.isNotEmpty) {
      _pendingPayload = response.payload;
      _pendingAction = response.actionId;
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('📱 FCM TOKEN (Copy untuk testing di Firebase Console):');
      print('╠═══════════════════════════════════════════════════════════╣');
      print(_fcmToken);
      print('╚═══════════════════════════════════════════════════════════╝');
      print('');

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('[NotificationService] Token refreshed: $newToken');
      });
    } catch (e) {
      print('[NotificationService] Error getting FCM token: $e');
    }
  }

  /// Setup FCM message handlers
  void _setupFCMHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        print('[NotificationService] App opened from terminated state');
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[FCM Foreground] Message received: ${message.messageId}');
    print('[FCM Foreground] Title: ${message.notification?.title}');
    print('[FCM Foreground] Body: ${message.notification?.body}');
    print('[FCM Foreground] Data: ${message.data}');

    await showLocalNotification(
      title: message.notification?.title ?? 'Notifikasi',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    print('[FCM Background Opened] Message: ${message.messageId}');
    print('[FCM Background Opened] Data: ${message.data}');

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

      print('[NotificationService] ✅ Local notification shown: $title');
    } catch (e) {
      print('[NotificationService] Error showing notification: $e');
    }
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
    int? id,
  }) async {
    try {
      final notificationId =
          id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      print('');
      print('╔════════════════════════════════════════════════════════╗');
      print('⏰ SCHEDULING NOTIFICATION');
      print('╠════════════════════════════════════════════════════════╣');
      print('ID: $notificationId');
      print('Title: $title');
      print('Body: $body');
      print('Current Time: ${tz.TZDateTime.now(tz.local)}');
      print('Scheduled Time: $scheduledDate');
      print('Delay: ${delay.inSeconds} seconds');
      print('Payload: $payload');
      print('╚════════════════════════════════════════════════════════╝');
      print('');

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
          AndroidNotificationAction(
            'snooze',
            '⏰ Ingatkan 10 detik lagi',
            showsUserInterface: false,
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
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('[NotificationService] ✅ Notification scheduled successfully!');
    } catch (e, stackTrace) {
      print('[NotificationService] ❌ Error scheduling notification: $e');
      print('[NotificationService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('[NotificationService] Notification $id cancelled');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
    print('[NotificationService] All scheduled notifications cancelled');
  }

  /// Handle notification tap (foreground)
  void _onNotificationTapped(NotificationResponse response) {
    print('');
    print('╔════════════════════════════════════════════════════════╗');
    print('👆 NOTIFICATION TAPPED');
    print('╠════════════════════════════════════════════════════════╣');
    print('Action ID: ${response.actionId}');
    print('Payload: ${response.payload}');
    print('╚════════════════════════════════════════════════════════╝');
    print('');

    if (response.actionId == 'mark_complete') {
      print('[NotificationService] 🎯 Executing mark_complete action');
      _handleMarkComplete(response.payload);
    } else if (response.actionId == 'snooze') {
      print('[NotificationService] 🎯 Executing snooze action');
      _handleSnooze(response.payload);
    } else {
      if (response.payload != null && response.payload!.isNotEmpty) {
        _navigateToTodo(response.payload!);
      }
    }
  }

  /// ✅ Handle mark complete action
  Future<void> _handleMarkComplete(String? payload) async {
    if (payload == null || payload.isEmpty) {
      print('[NotificationService] ❌ Payload is null or empty');
      return;
    }

    print('[NotificationService] ✅ Processing mark complete: $payload');

    try {
      // Try controller first (if app is running)
      if (Get.isRegistered<TodoController>()) {
        final todoController = Get.find<TodoController>();
        await todoController.toggleComplete(payload);
        print('[NotificationService] ✅ Completed via controller');
      } else {
        // Fallback: Direct Firestore update
        print(
            '[NotificationService] ⚠️ Controller not available, using direct Firestore');
        await _markTodoCompleteDirectly(payload);
      }

      await showLocalNotification(
        title: '✅ Todo Selesai!',
        body: 'Todo berhasil ditandai selesai',
      );
    } catch (e) {
      print('[NotificationService] ❌ Error: $e');

      await showLocalNotification(
        title: '❌ Error',
        body: 'Gagal menandai todo selesai',
      );
    }
  }

  /// ✅ Mark todo complete directly via Firestore
  Future<void> _markTodoCompleteDirectly(String todoId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        print('[NotificationService] ❌ No user logged in');
        throw Exception('User not logged in');
      }

      // Get current todo
      final todoDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .get();

      if (!todoDoc.exists) {
        print('[NotificationService] ❌ Todo not found: $todoId');
        throw Exception('Todo not found');
      }

      final currentCompleted = todoDoc.data()?['completed'] ?? false;

      // Toggle completed
      await firestore
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .update({
        'completed': !currentCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('[NotificationService] ✅ Todo marked complete directly: $todoId');
    } catch (e) {
      print('[NotificationService] ❌ Error in direct Firestore update: $e');
      rethrow;
    }
  }

  /// ✅ Handle snooze action
  Future<void> _handleSnooze(String? payload) async {
    if (payload == null || payload.isEmpty) {
      print('[NotificationService] ❌ Snooze payload is null or empty');
      return;
    }

    print('');
    print('╔════════════════════════════════════════════════════════╗');
    print('⏰ SNOOZE TRIGGERED');
    print('╠════════════════════════════════════════════════════════╣');
    print('Payload: $payload');
    print('Delay: 10 seconds');
    print('╚════════════════════════════════════════════════════════╝');
    print('');

    try {
      await scheduleNotification(
        title: '⏰ Reminder: Todo',
        body: 'Jangan lupa selesaikan todo ini!',
        delay: const Duration(seconds: 10),
        payload: payload,
      );

      await showLocalNotification(
        title: '⏰ Reminder Ditunda',
        body: 'Kamu akan diingatkan lagi dalam 10 detik',
      );

      print('[NotificationService] ✅ Snooze scheduled successfully');
    } catch (e) {
      print('[NotificationService] ❌ Error snoozing: $e');

      await showLocalNotification(
        title: '❌ Error',
        body: 'Gagal mengatur reminder',
      );
    }
  }

  /// Navigate to todo detail
  void _navigateToTodo(String todoId) {
    print('[NotificationService] Navigating to todo: $todoId');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isRegistered<dynamic>()) {
        // Tambahkan routing sesuai app kamu
        // Get.toNamed('/todo-detail', arguments: {'todoId': todoId});
        print('[NotificationService] Navigate to todo: $todoId');
      }
    });
  }

  /// Check pending payload and process it
  void processPendingPayload() {
    if (_pendingPayload != null) {
      print(
          '[NotificationService] Processing pending payload: $_pendingPayload');
      print('[NotificationService] Processing pending action: $_pendingAction');

      if (_pendingAction == 'mark_complete') {
        _handleMarkComplete(_pendingPayload);
      } else if (_pendingAction == 'snooze') {
        _handleSnooze(_pendingPayload);
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
    print('[NotificationService] Pending notifications: ${pending.length}');
    for (var notif in pending) {
      print('  - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
    }
    return pending;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      print('[NotificationService] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      print('[NotificationService] Error unsubscribing from topic: $e');
    }
  }
}
