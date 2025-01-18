import 'package:flutter/material.dart';

import '../../core/services/home/dailyWord_service.dart';
import '../../core/services/notifications/notifications_service.dart';
import '../../models/home/daily_word_model.dart';

class DailyWordViewModel extends ChangeNotifier {
  final DailyWordService _dailyWordService;
  final NotificationService _notificationService = NotificationService();

  DailyWordModel? _dailyWord;
  bool _isLoading = false;
  String? _error;
  bool _isNotificationScheduled = false;

  DailyWordViewModel({required DailyWordService dailyWordService})
      : _dailyWordService = dailyWordService;

  // Getters
  DailyWordModel? get dailyWord => _dailyWord;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isNotificationScheduled => _isNotificationScheduled;

  Future<void> loadDailyWord(BuildContext context) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _clearError();
      notifyListeners();

      // Load daily word
      _dailyWord = await _dailyWordService.getTodayDailyWord();

      // Schedule notification if daily word exists and not already scheduled
      if (_dailyWord != null && !_isNotificationScheduled) {
        try {
          await _notificationService.scheduleDailyWordNotification(
            _dailyWord!,
            context,
          );
          _isNotificationScheduled = true;
        } catch (notifError) {
          print('Error scheduling notification: $notifError');
          // Log error but don't show to user
          _logError('Notification scheduling failed: $notifError');
        }
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      print('Error loading daily word: $e');
      _handleError(e);
    }
  }

  void refresh(BuildContext context) async {
    if (_isLoading) return;

    _dailyWord = null;
    _error = null;
    _isNotificationScheduled = false;
    await loadDailyWord(context);
  }

  void _handleError(dynamic error) {
    String errorMessage = 'Gagal memuat Firman Hari Ini';

    if (error is Exception) {
      print('Exception occurred: $error');
      // You can add specific error handling based on error type
      if (error.toString().contains('permission-denied')) {
        errorMessage = 'Tidak memiliki akses untuk memuat Firman Hari Ini';
      } else if (error.toString().contains('network')) {
        errorMessage = 'Koneksi terputus. Silakan coba lagi.';
      }
    }

    _setError(errorMessage);
    _logError('Error in DailyWordViewModel: $error');
  }

  void _logError(String errorMessage) {
    // Add logging implementation here
    print('DailyWordViewModel Error: $errorMessage');
  }

  void _clearError() {
    _error = null;
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String? value) {
    _error = value;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _dailyWord = null;
    _error = null;
    _isLoading = false;
    super.dispose();
  }
}
