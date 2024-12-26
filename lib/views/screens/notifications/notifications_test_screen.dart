import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../core/services/notifications/notifications_service.dart';
import '../../../main.dart';
import '../../../models/event/event_model.dart';
import '../../../models/home/daily_word_model.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifikasi'),
        backgroundColor: const Color(0xFF132054),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Test Daily Word Notification
          _buildTestSection(
            title: 'Daily Word Notification',
            children: [
              ElevatedButton(
                onPressed: () => _testDailyWordNotification(context),
                child: const Text('Test 30 Detik'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Test Event Notification
          _buildTestSection(
            title: 'Event Notification',
            children: [
              ElevatedButton(
                onPressed: () => _testEventNotification(context),
                child: const Text('Test 1 Menit'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Test Birthday Notification
          _buildTestSection(
            title: 'Birthday Notification',
            children: [
              ElevatedButton(
                onPressed: () => _testBirthdayNotification(context),
                child: const Text('Test 2 Menit'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Utility Buttons
          _buildTestSection(
            title: 'Utilities',
            children: [
              ElevatedButton(
                onPressed: () => _checkPendingNotifications(context),
                child: const Text('Check Pending Notifications'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _clearAllNotifications(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Clear All Notifications'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _testDailyWordNotification(BuildContext context) async {
    try {
      await Provider.of<NotificationService>(context, listen: false)
          .testDailyWordNotification(context);
      _showSuccessSnackBar(context, 'Daily Word notification scheduled');
    } catch (e) {
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _testEventNotification(BuildContext context) async {
    try {
      await Provider.of<NotificationService>(context, listen: false)
          .testEventNotification(context);
      _showSuccessSnackBar(context, 'Event notification scheduled');
    } catch (e) {
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _testBirthdayNotification(BuildContext context) async {
    try {
      await Provider.of<NotificationService>(context, listen: false)
          .testBirthdayNotification(context);
      _showSuccessSnackBar(context, 'Birthday notification scheduled');
    } catch (e) {
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _checkPendingNotifications(BuildContext context) async {
    try {
      final pending =
          await Provider.of<NotificationService>(context, listen: false)
              .getPendingNotifications();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pending Notifications'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: pending
                  .map((notification) => ListTile(
                        title: Text('ID: ${notification.id}'),
                        subtitle: Text(notification.title ?? 'No title'),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _clearAllNotifications(BuildContext context) async {
    try {
      await Provider.of<NotificationService>(context, listen: false)
          .clearAllNotifications();
      _showSuccessSnackBar(context, 'All notifications cleared');
    } catch (e) {
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
