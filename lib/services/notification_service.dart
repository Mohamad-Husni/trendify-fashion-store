import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // order, promotion, system
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String id) {
    return AppNotification(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  bool _notificationsEnabled = true;
  String? _fcmToken;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;

  String? get _userId => _auth.currentUser?.uid;

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _notificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      print('FCM Token: $_fcmToken');

      // Save token to Firestore
      if (_fcmToken != null && _userId != null) {
        await _saveToken(_fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) async {
        _fcmToken = token;
        if (_userId != null) {
          await _saveToken(token);
        }
      });

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Load notifications
      await loadNotifications();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveToken(String token) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'platform': defaultTargetPlatform.toString(),
        'tokenUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );

    // Add to notifications list
    await loadNotifications();
  }

  // Handle message opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Message opened app: ${message.notification?.title}');
    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('orderId')) {
      // Navigate to order details
    } else if (data.containsKey('productId')) {
      // Navigate to product details
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'trendify_channel',
      'TRENDIFY Notifications',
      channelDescription: 'Notifications for orders, offers, and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
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
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation
  }

  // Load notifications from Firestore
  Future<void> loadNotifications() async {
    final userId = _userId;
    if (userId == null) {
      _notifications = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data(), doc.id))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update local cache
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          data: _notifications[index].data,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        final ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notification.id);
        batch.update(ref, {'isRead': true});
      }

      await batch.commit();

      // Update local cache
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                title: n.title,
                body: n.body,
                type: n.type,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Test notification (send to self)
  Future<void> sendTestNotification() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      // Add notification to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Test Notification',
        'body': 'This is a test notification from TRENDIFY!',
        'type': 'system',
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      await loadNotifications();
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  // Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    final userId = _userId;
    if (userId != null) {
      try {
        await _firestore.collection('users').doc(userId).update({
          'notificationsEnabled': enabled,
        });
      } catch (e) {
        print('Error updating notification settings: $e');
      }
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      _notifications.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Handle background messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  // Handle background message
}
