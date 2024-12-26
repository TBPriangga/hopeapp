import 'package:flutter/material.dart';

import '../../core/services/notifications/notifications_service.dart';
import '../../models/notifications/notifications_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Get notifications stream
  Stream<List<NotificationModel>> getNotifications() {
    return _notificationService.getNotifications();
  }

  // Initialize
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      _setupListeners();
    } catch (e) {
      _error = 'Failed to initialize notifications: $e';
      notifyListeners();
    }
  }

  void _setupListeners() {
    // Listen to notifications
    _notificationService.getNotifications().listen(
      (notifications) {
        _notifications = notifications;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load notifications: $error';
        notifyListeners();
      },
    );

    // Listen to unread count
    _notificationService.getUnreadCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        print('Error getting unread count: $error');
      },
    );
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
