import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Models
import '../../../models/event/event_model.dart';
import '../../../models/home/daily_word_model.dart';
import '../../../models/notifications/notifications_model.dart';

class NotificationRetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;

  NotificationRetryConfig({
    required this.maxAttempts,
    required this.initialDelay,
    required this.maxDelay,
    required this.backoffMultiplier,
  });
}

class NotificationRetryService {
  final NotificationRetryConfig config;

  NotificationRetryService({required this.config});

  Future<void> retry<T>(
    Future<void> Function() action, {
    required String operationType,
    required Map<String, dynamic> metadata,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (attempt < config.maxAttempts) {
      try {
        attempt++;
        await action();
        FirebaseFirestore.instance.collection('notification_retry_logs').add({
          'type': operationType,
          'success': true,
          'attempt': attempt,
          'metadata': metadata,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        FirebaseFirestore.instance.collection('notification_retry_logs').add({
          'type': operationType,
          'success': false,
          'attempt': attempt,
          'error': e.toString(),
          'metadata': metadata,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (attempt >= config.maxAttempts) {
          rethrow;
        }

        await Future.delayed(delay);
        delay = delay * config.backoffMultiplier;
        if (delay > config.maxDelay) delay = config.maxDelay;
      }
    }
  }
}

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationRetryService _retryService = NotificationRetryService(
    config: NotificationRetryConfig(
      maxAttempts: 3,
      initialDelay: Duration(seconds: 1),
      maxDelay: Duration(minutes: 1),
      backoffMultiplier: 2.0,
    ),
  );

  static const int DAILY_WORD_NOTIFICATION_ID = 1;
  static const int EVENT_NOTIFICATION_ID = 2;
  static const int BIRTHDAY_NOTIFICATION_ID = 3;

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@drawable/notification_icon');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      await _requestNotificationPermissions();
      await setupChannelGroups();
      await _setupFCMToken();
      await subscribeToTopics();

      Timer.periodic(const Duration(hours: 1), (_) {
        retryFailedNotifications();
      });
    } catch (e) {
      await _logNotificationError(
        'initialization',
        'Unexpected error during initialization: $e',
      );
      rethrow;
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await _logNotificationError(
        'permissions',
        'Notification permissions not granted: ${settings.authorizationStatus}',
      );
    }
  }

  Future<void> _setupFCMToken() async {
    final token = await _messaging.getToken();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (token != null && userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});

      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'fcmToken': newToken});
      });
    }
  }

  Future<void> setupChannelGroups() async {
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (platform != null) {
      await platform.createNotificationChannelGroup(
        const AndroidNotificationChannelGroup(
          'spiritual_group',
          'Spiritual',
          description: 'Notifikasi terkait kerohanian',
        ),
      );

      await platform.createNotificationChannelGroup(
        const AndroidNotificationChannelGroup(
          'events_group',
          'Events',
          description: 'Notifikasi terkait acara gereja',
        ),
      );

      await platform.createNotificationChannelGroup(
        const AndroidNotificationChannelGroup(
          'social_group',
          'Social',
          description: 'Notifikasi terkait sosial',
        ),
      );

      await platform.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_word_channel',
          'Renungan Harian',
          description: 'Notifikasi untuk renungan harian',
          groupId: 'spiritual_group',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      await platform.createNotificationChannel(
        const AndroidNotificationChannel(
          'event_channel',
          'Event Notifications',
          description: 'Notifikasi untuk event gereja',
          groupId: 'events_group',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      await platform.createNotificationChannel(
        const AndroidNotificationChannel(
          'birthday_channel',
          'Birthday Notifications',
          description: 'Notifikasi untuk ulang tahun jemaat',
          groupId: 'social_group',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  Future<void> scheduleDailyWordNotification(
    DailyWordModel dailyWord,
    BuildContext context,
  ) async {
    await _retryService.retry(
      () async {
        await _localNotifications.cancel(DAILY_WORD_NOTIFICATION_ID);

        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final scheduledDate = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          5,
          0,
        );

        if (scheduledDate.isBefore(now)) {
          throw Exception('Scheduled date must be in the future');
        }

        final androidDetails = AndroidNotificationDetails(
          'daily_word_channel',
          'Renungan Harian',
          channelDescription: 'Notifikasi untuk renungan harian',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF132054),
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );

        final details = NotificationDetails(android: androidDetails);

        final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

        await _localNotifications.zonedSchedule(
          DAILY_WORD_NOTIFICATION_ID,
          'Renungan Hari Ini',
          dailyWord.verse,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: json.encode({
            'type': 'daily_word',
            'verse': dailyWord.verse,
          }),
        );

        await _firestore.collection('notification_logs').add({
          'type': 'daily_word_schedule',
          'success': true,
          'scheduledFor': scheduledTime.toIso8601String(),
          'verse': dailyWord.verse,
          'timestamp': FieldValue.serverTimestamp(),
        });
      },
      operationType: 'schedule_daily_word',
      metadata: {
        'verse': dailyWord.verse,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> sendEventNotification(
    EventModel event,
    BuildContext context,
  ) async {
    await _retryService.retry(
      () async {
        try {
          final eventDate = event.date;
          final now = DateTime.now();
          final threeDaysBefore = eventDate.subtract(const Duration(days: 3));
          final oneDayBefore = eventDate.subtract(const Duration(days: 1));

          final androidDetails = AndroidNotificationDetails(
            'event_channel',
            'Event Notifications',
            channelDescription: 'Notifikasi untuk event gereja',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF132054),
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          );

          final details = NotificationDetails(android: androidDetails);

          await _localNotifications.cancel(EVENT_NOTIFICATION_ID);
          await _localNotifications.cancel(EVENT_NOTIFICATION_ID + 1);
          await _localNotifications.cancel(EVENT_NOTIFICATION_ID + 2);

          if (now.isBefore(threeDaysBefore)) {
            final scheduledTime = await _nextInstanceOfTime(9, 0);
            await _scheduleEventNotification(
              event,
              scheduledTime,
              '📅 Event dalam 3 hari',
              details,
              EVENT_NOTIFICATION_ID,
            );
          }

          if (now.isBefore(oneDayBefore)) {
            final scheduledTime = await _nextInstanceOfTime(9, 0);
            await _scheduleEventNotification(
              event,
              scheduledTime,
              '📅 Event besok!',
              details,
              EVENT_NOTIFICATION_ID + 1,
            );
          }

          if (now.isBefore(eventDate)) {
            final scheduledTime = await _nextInstanceOfTime(9, 0);
            await _scheduleEventNotification(
              event,
              scheduledTime,
              '🎉 Event hari ini!',
              details,
              EVENT_NOTIFICATION_ID + 2,
            );
          }

          await _logEventNotification(event);
        } catch (e) {
          await _logNotificationError('event', e.toString());
          rethrow;
        }
      },
      operationType: 'send_event_notification',
      metadata: {'eventId': event.id},
    );
  }

  Future<void> _scheduleEventNotification(
    EventModel event,
    tz.TZDateTime scheduledTime,
    String title,
    NotificationDetails details,
    int id,
  ) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      event.title,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'type': 'event',
        'eventId': event.id,
      }),
    );
  }

  Future<void> sendBirthdayNotification(
    List<String> celebrants,
    BuildContext context,
  ) async {
    await _retryService.retry(
      () async {
        await _localNotifications.cancel(BIRTHDAY_NOTIFICATION_ID);

        final androidDetails = AndroidNotificationDetails(
          'birthday_channel',
          'Birthday Notifications',
          channelDescription: 'Notifikasi untuk ulang tahun jemaat',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF132054),
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );

        final details = NotificationDetails(android: androidDetails);

        final message = celebrants.length == 1
            ? 'Hari ini adalah ulang tahun ${celebrants[0]}! Mari doakan bersama!'
            : 'Hari ini adalah ulang tahun ${celebrants.join(", ")}! Mari doakan mereka bersama!';

        final scheduledTime = await _nextInstanceOfTime(7, 0);

        await _localNotifications.zonedSchedule(
          BIRTHDAY_NOTIFICATION_ID,
          '🎂 Selamat Ulang Tahun!',
          message,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: json.encode({
            'type': 'birthday',
            'celebrants': celebrants,
          }),
        );

        await _firestore.collection('notification_logs').add({
          'type': 'birthday_notification',
          'success': true,
          'celebrants': celebrants,
          'scheduledFor': scheduledTime.toIso8601String(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      },
      operationType: 'schedule_birthday',
      metadata: {
        'celebrants': celebrants,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      final notification = message.notification;

      if (notification != null) {
        await _firestore.collection('notification_logs').add({
          'type': 'background_message',
          'title': notification.title,
          'body': notification.body,
          'data': data,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
        await _showBackgroundNotification(notification, data);
      }
    } catch (e) {
      await _logNotificationError('background_message', e.toString());
    }
  }

  Future<void> _showBackgroundNotification(
    RemoteNotification notification,
    Map<String, dynamic> data,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      data['channel'] ?? 'default_channel',
      data['channel_name'] ?? 'Default Channel',
      channelDescription:
          data['channel_description'] ?? 'Default channel for notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: json.encode(data),
    );
  }

  Future<tz.TZDateTime> _nextInstanceOfTime(int hour, int minute) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> retryFailedNotifications() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final failedNotifications = await _firestore
          .collection('notification_logs')
          .where('success', isEqualTo: false)
          .where('timestamp', isGreaterThan: yesterday)
          .where('retryCount', isLessThan: 3)
          .get();

      for (final doc in failedNotifications.docs) {
        final data = doc.data();
        final type = data['type'] as String;
        final retryCount = (data['retryCount'] as int?) ?? 0;

        await doc.reference.update({
          'retryCount': retryCount + 1,
          'lastRetryAt': FieldValue.serverTimestamp(),
        });

        switch (type) {
          case 'daily_word_schedule':
            if (data['verse'] != null) {
              await _retryDailyWordNotification(data);
            }
            break;
          case 'event_notification':
            if (data['eventId'] != null) {
              await _retryEventNotification(data);
            }
            break;
          case 'birthday_notification':
            if (data['celebrants'] != null) {
              await _retryBirthdayNotification(data);
            }
            break;
        }
      }
    } catch (e) {
      await _logNotificationError('retry_failed_notifications', e.toString());
    }
  }

  Future<void> _retryDailyWordNotification(Map<String, dynamic> data) async {
    final androidDetails = AndroidNotificationDetails(
      'daily_word_channel',
      'Renungan Harian',
      channelDescription: 'Notifikasi untuk renungan harian',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);

    final scheduledTime = await _nextInstanceOfTime(5, 0); // 5 AM

    await _localNotifications.zonedSchedule(
      DAILY_WORD_NOTIFICATION_ID,
      'Renungan Hari Ini',
      data['verse'],
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: json.encode({
        'type': 'daily_word',
        'verse': data['verse'],
      }),
    );
  }

  Future<void> _retryEventNotification(Map<String, dynamic> data) async {
    // Implementation for retrying event notification
    // Similar to _retryDailyWordNotification but for events
  }

  Future<void> _retryBirthdayNotification(Map<String, dynamic> data) async {
    // Implementation for retrying birthday notification
    // Similar to _retryDailyWordNotification but for birthdays
  }

  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      await _firestore.collection('notification_logs').add({
        'type': 'notification_cancel',
        'notificationId': id,
        'timestamp': FieldValue.serverTimestamp(),
        'success': true,
      });
    } catch (e) {
      await _logNotificationError(
        'notification_cancel',
        'Failed to cancel notification $id: $e',
      );
      rethrow;
    }
  }

  Future<bool> isNotificationScheduled(int id) async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _localNotifications.pendingNotificationRequests();
    return pendingNotifications.any((notification) => notification.id == id);
  }

  Stream<int> getUnreadCount() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<NotificationModel>> getNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print('Notification data: ${doc.data()}'); // Untuk debugging
        return NotificationModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        final navigatorState = navigatorKey.currentState;

        if (navigatorState != null) {
          switch (data['type']) {
            case 'daily_word':
              navigatorState.pushNamed('/daily-word');
              break;
            case 'event':
              if (data['eventId'] != null) {
                navigatorState.pushNamed('/event-detail',
                    arguments: data['eventId']);
              }
              break;
            case 'birthday':
              navigatorState.pushNamed('/birthdays');
              break;
          }
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }

  Future<void> _logNotificationError(String type, String error) async {
    try {
      await _firestore.collection('notification_logs').add({
        'type': type,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
        'success': false,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging notification error: $e');
    }
  }

  Future<void> _logEventNotification(EventModel event) async {
    await _firestore.collection('notification_logs').add({
      'type': 'event_notification',
      'eventId': event.id,
      'eventTitle': event.title,
      'timestamp': FieldValue.serverTimestamp(),
      'success': true,
    });
  }

  Future<void> subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('daily_word');
      await _messaging.subscribeToTopic('events');
      await _messaging.subscribeToTopic('birthdays');

      await _firestore.collection('notification_logs').add({
        'type': 'topic_subscription',
        'success': true,
        'topics': ['daily_word', 'events', 'birthdays'],
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      await _logNotificationError('topic_subscription', e.toString());
      rethrow;
    }
  }

  Future<void> unsubscribeFromTopics() async {
    try {
      await _messaging.unsubscribeFromTopic('daily_word');
      await _messaging.unsubscribeFromTopic('events');
      await _messaging.unsubscribeFromTopic('birthdays');

      await _firestore.collection('notification_logs').add({
        'type': 'topic_unsubscription',
        'success': true,
        'topics': ['daily_word', 'events', 'birthdays'],
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      await _logNotificationError('topic_unsubscription', e.toString());
      rethrow;
    }
  }

  // Test scheduled notification
  Future<void> testScheduledNotification({
    required String title,
    required String body,
    required Duration delay,
    required String channelId,
    required String payload,
  }) async {
    final scheduledTime = DateTime.now().add(delay);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
      channelDescription: 'Test notification for $channelId',
      playSound: true,
      enableVibration: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.zonedSchedule(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    // Log the scheduled notification
    await _firestore.collection('notification_logs').add({
      'type': 'test_notification',
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'channelId': channelId,
      'success': true,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Test daily word notification
  Future<void> testDailyWordNotification(BuildContext context) async {
    final dailyWord = DailyWordModel(
      id: 'test_id',
      verse: 'Test Daily Word',
      content: 'This is a test daily word notification',
      description: 'Test Description',
      bibleUrl: 'https://example.com',
      date: DateTime.now(),
      isActive: true,
    );

    await testScheduledNotification(
      title: 'Daily Word Test',
      body: dailyWord.verse,
      delay: const Duration(seconds: 30),
      channelId: 'daily_word_channel',
      payload: json.encode({
        'type': 'daily_word',
        'verse': dailyWord.verse,
      }),
    );
  }

  // Test event notification
  Future<void> testEventNotification(BuildContext context) async {
    final event = EventModel(
      id: 'test_event',
      title: 'Test Event',
      date: DateTime.now().add(const Duration(minutes: 1)),
      location: 'Test Location',
      imageUrl: 'test_image_url',
      imageDetailUrl: 'test_detail_url',
      description: 'Test Description',
      createdAt: DateTime.now(),
    );

    await testScheduledNotification(
      title: 'Event Test',
      body: event.title,
      delay: const Duration(minutes: 1),
      channelId: 'event_channel',
      payload: json.encode({
        'type': 'event',
        'eventId': event.id,
      }),
    );
  }

  // Test birthday notification
  Future<void> testBirthdayNotification(BuildContext context) async {
    final celebrants = ['John Doe', 'Jane Doe'];

    await testScheduledNotification(
      title: 'Birthday Test',
      body: 'Test birthday notification for ${celebrants.join(", ")}',
      delay: const Duration(minutes: 2),
      channelId: 'birthday_channel',
      payload: json.encode({
        'type': 'birthday',
        'celebrants': celebrants,
      }),
    );
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();

      // Log the action
      await _firestore.collection('notification_logs').add({
        'type': 'clear_all',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'success': true,
      });
    } catch (e) {
      print('Error clearing notifications: $e');
      await _logNotificationError('clear_all', e.toString());
      throw e;
    }
  }

  Future<void> saveNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? eventId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'message': message,
      'type': type.toString(),
      'eventId': eventId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
