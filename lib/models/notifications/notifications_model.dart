import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationType { event, announcement, reminder, general }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? eventId;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    required this.createdAt,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.general,
      ),
      eventId: map['eventId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      additionalData: map['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString(),
      'eventId': eventId,
      'createdAt': createdAt,
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    NotificationType? type,
    String? eventId,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Added helper methods
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy', 'id_ID').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.event:
        return Icons.event;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.announcement:
        return Colors.orange;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}
