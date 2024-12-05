import 'package:flutter/material.dart';
import '../../models/home/daily_word_model.dart';
import '../../core/services/home/dailyWord_service.dart';

class DailyWordListViewModel extends ChangeNotifier {
  final DailyWordService _dailyWordService;

  DailyWordListViewModel({required DailyWordService dailyWordService})
      : _dailyWordService = dailyWordService;

  List<DailyWordModel> _dailyWords = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String? _searchQuery;

  // Getters
  List<DailyWordModel> get dailyWords => _dailyWords;
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    _dailyWords.clear();
    _hasMore = true;
    _error = null;
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
      _dailyWords = results;
      _hasMore = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
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
