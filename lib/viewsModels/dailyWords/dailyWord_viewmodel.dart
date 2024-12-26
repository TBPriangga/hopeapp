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

  DailyWordViewModel({required DailyWordService dailyWordService})
      : _dailyWordService = dailyWordService;

  // Getters
  DailyWordModel? get dailyWord => _dailyWord;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDailyWord(BuildContext context) async {
    try {
      _setLoading(true);
      _error = null;

      _dailyWord = await _dailyWordService.getTodayDailyWord();

      // Schedule notification for tomorrow if dailyWord exists
      if (_dailyWord != null) {
        await _notificationService.scheduleDailyWordNotification(
          _dailyWord!,
          context,
        );
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    _isLoading = false;
    notifyListeners();
  }
}
