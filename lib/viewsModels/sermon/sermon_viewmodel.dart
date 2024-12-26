import 'package:flutter/material.dart';
import '../../core/services/sermon/sermon_service.dart';
import '../../models/sermon/sermon_model.dart';
import '../../models/sermon/sermon_series_model.dart';

class SermonViewModel extends ChangeNotifier {
  final SermonService _sermonService;

  SermonViewModel({
    required SermonService sermonService,
  }) : _sermonService = sermonService;

  // State untuk series
  List<SermonSeries> _sermonSeries = [];
  SermonSeries? _selectedSeries;
  bool _isLoadingSeries = false;
  String? _seriesError;

  // State untuk list sermon
  List<SermonModel> _sermons = [];
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'terbaru';

  // State untuk detail sermon
  SermonModel? _selectedSermon;
  List<SermonModel> _relatedSermons = [];
  bool _isLoadingDetail = false;
  String? _detailError;

  // Getters untuk series
  List<SermonSeries> get sermonSeries => _sermonSeries;
  SermonSeries? get selectedSeries => _selectedSeries;
  bool get isLoadingSeries => _isLoadingSeries;
  String? get seriesError => _seriesError;

  // Getters yang sudah ada
  List<SermonModel> get sermons => _sermons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;

  SermonModel? get selectedSermon => _selectedSermon;
  List<SermonModel> get relatedSermons => _relatedSermons;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // Load sermon series
  Future<void> loadSermonSeries() async {
    if (_isLoadingSeries) return;

    try {
      _isLoadingSeries = true;
      _seriesError = null;
      notifyListeners();

      _sermonSeries = await _sermonService.getActiveSermonSeries();

      _isLoadingSeries = false;
      notifyListeners();
    } catch (e) {
      _seriesError = e.toString();
      _isLoadingSeries = false;
      notifyListeners();
    }
  }

  // Set series tanpa load sermons
  void setSelectedSeries(SermonSeries series) {
    _selectedSeries = series;
    notifyListeners();
  }

  // Load khotbah berdasarkan series
  Future<void> loadSermonsBySeries(String seriesId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final sermons = await _sermonService.getSermonsBySeriesId(seriesId);
      _sermons = sermons;
      _applySorting();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applySorting() {
    if (_sortBy == 'terlama') {
      _sermons.sort((a, b) => a.date.compareTo(b.date));
    } else {
      _sermons.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  void setSortBy(String value) {
    _sortBy = value;
    _applySorting();
    notifyListeners();
  }

  Future<void> loadSermonDetail(String sermonId) async {
    if (_isLoadingDetail) return;

    try {
      _isLoadingDetail = true;
      _detailError = null;
      notifyListeners();

      final result = await _sermonService.getSermonWithSeries(sermonId);
      _selectedSermon = result['sermon'] as SermonModel;
      _selectedSeries = result['series'] as SermonSeries?;

      if (_selectedSermon != null) {
        await _loadRelatedSermons(sermonId, _selectedSermon!.seriesId);
      }

      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _detailError = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> _loadRelatedSermons(
      String currentSermonId, String seriesId) async {
    try {
      final sermons = await _sermonService.getRelatedSermons(
        seriesId: seriesId,
        currentSermonId: currentSermonId,
        limit: 3,
      );
      _relatedSermons = sermons;
      notifyListeners();
    } catch (error) {
      print('Error loading related sermons: $error');
      _relatedSermons = [];
      notifyListeners();
    }
  }

  void clearSelectedSermon() {
    _selectedSermon = null;
    _relatedSermons = [];
    _detailError = null;
    _isLoadingDetail = false;
    notifyListeners();
  }

  void clearSelectedSeries() {
    _selectedSeries = null;
    _sermons = [];
    clearSelectedSermon();
    notifyListeners();
  }

  void clearAll() {
    _sermonSeries = [];
    _seriesError = null;
    _isLoadingSeries = false;
    clearSelectedSeries();
  }

  // Refresh semua data
  Future<void> refresh() async {
    clearAll();
    await loadSermonSeries();
  }
}
