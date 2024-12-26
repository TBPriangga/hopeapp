// Path: lib/core/services/notifications/notification_permission_handler.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notifications_service.dart';

class NotificationPermissionHandler {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Check current notification permission status
  Future<bool> checkPermissionStatus() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          print('User granted notification permission');
          return true;
        case AuthorizationStatus.provisional:
          print('User granted provisional notification permission');
          return true;
        case AuthorizationStatus.denied:
          print('User declined notification permission');
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Ensure notification permissions before sending
  Future<bool> ensurePermission() async {
    bool hasPermission = await checkPermissionStatus();

    if (!hasPermission) {
      hasPermission = await requestPermission();
    }

    return hasPermission;
  }
}

// Extension untuk NotificationService
extension PermissionHandling on NotificationService {
  Future<bool> checkAndRequestPermission() async {
    final permissionHandler = NotificationPermissionHandler();
    return await permissionHandler.ensurePermission();
  }

  // Helper untuk mengecek permission sebelum kirim notifikasi
  Future<void> sendNotificationWithPermissionCheck({
    required Future<void> Function() notificationFunction,
    required BuildContext context,
  }) async {
    final permissionHandler = NotificationPermissionHandler();
    final hasPermission = await permissionHandler.ensurePermission();

    if (!hasPermission) {
      // Show dialog to guide user to settings
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Permission Required'),
            content: const Text(
                'To receive notifications, please enable notifications in your device settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Open app settings
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Execute notification function if permission granted
    await notificationFunction();
  }
}
