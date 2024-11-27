import 'package:flutter/material.dart';
import '../../core/services/home/birthday_service.dart';
import '../../models/home/birthday_model.dart';

class BirthdayViewModel extends ChangeNotifier {
  final BirthdayService _birthdayService = BirthdayService();

  List<BirthdayModel> _birthdays = [];
  bool _isLoading = false;
  String? _error;

  List<BirthdayModel> get birthdays => _birthdays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeeklyBirthdays() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _birthdays = await _birthdayService.getWeeklyBirthdays();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load birthdays: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
