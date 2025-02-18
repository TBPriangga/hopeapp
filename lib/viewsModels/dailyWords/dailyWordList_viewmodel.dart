import 'package:flutter/material.dart';
import '../../models/home/daily_word_model.dart';
import '../../core/services/home/dailyWord_service.dart';

class DailyWordListViewModel extends ChangeNotifier {
  final DailyWordService _dailyWordService;

  DailyWordListViewModel({required DailyWordService dailyWordService})
      : _dailyWordService = dailyWordService;

  List<DailyWordModel> _dailyWords = [];
  List<DailyWordModel> _filteredDailyWords = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String? _searchQuery;
  DateTime? _selectedMonth;

  // Getters
  List<DailyWordModel> get dailyWords =>
      _filteredDailyWords.isEmpty ? _dailyWords : _filteredDailyWords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadDailyWords({int limit = 15}) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;

      final lastDocument = _dailyWords.isNotEmpty ? _dailyWords.last : null;
      final newDailyWords = await _dailyWordService.getPastDailyWords(
        lastDocument: lastDocument,
        limit: limit,
      );

      _dailyWords.addAll(newDailyWords);
      _hasMore = newDailyWords.length == limit;

      // Jika ada filter bulan aktif, terapkan kembali
      if (_selectedMonth != null) {
        _applyMonthFilter();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void filterByMonth(DateTime selectedDate) {
    _selectedMonth = selectedDate;
    _applyMonthFilter();
  }

  void _applyMonthFilter() {
    if (_selectedMonth == null) {
      _filteredDailyWords = [];
      notifyListeners();
      return;
    }

    _filteredDailyWords = _dailyWords.where((dailyWord) {
      return dailyWord.date.year == _selectedMonth!.year &&
          dailyWord.date.month == _selectedMonth!.month;
    }).toList();

    notifyListeners();
  }

  Future<void> refresh() async {
    _dailyWords.clear();
    _filteredDailyWords.clear();
    _hasMore = true;
    _error = null;
    _selectedMonth = null;
    await loadDailyWords();
  }

  Future<void> searchDailyWords(String query) async {
    if (query.isEmpty) {
      await refresh();
      return;
    }

    try {
      _setLoading(true);
      _error = null;
      _searchQuery = query;

      final results = await _dailyWordService.searchDailyWords(query);

      if (_selectedMonth != null) {
        // Filter hasil pencarian berdasarkan bulan yang dipilih
        _filteredDailyWords = results.where((dailyWord) {
          return dailyWord.date.year == _selectedMonth!.year &&
              dailyWord.date.month == _selectedMonth!.month;
        }).toList();
      } else {
        _dailyWords = results;
        _filteredDailyWords = [];
      }

      _hasMore = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearFilter() {
    _selectedMonth = null;
    _filteredDailyWords = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
