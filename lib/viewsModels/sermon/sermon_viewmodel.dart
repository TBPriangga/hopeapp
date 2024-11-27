import 'package:flutter/material.dart';

import '../../core/services/sermon/sermon_service.dart';
import '../../models/sermon/sermon_model.dart';

class SermonViewModel extends ChangeNotifier {
  final SermonService _sermonService = SermonService();

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

  // Getters
  List<SermonModel> get sermons => _sermons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;

  SermonModel? get selectedSermon => _selectedSermon;
  List<SermonModel> get relatedSermons => _relatedSermons;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // Load sermons list
  Future<void> loadSermons() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _sermonService.getLatestSermons().listen(
        (sermons) {
          _sermons = sermons;
          if (_sortBy == 'terlama') {
            _sermons = _sermons.reversed.toList();
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set sort order
  void setSortBy(String value) {
    _sortBy = value;
    if (value == 'terlama') {
      _sermons = _sermons.reversed.toList();
    } else {
      _sermons = _sermons.reversed.toList();
    }
    notifyListeners();
  }

  // Load sermon detail
  Future<void> loadSermonDetail(String sermonId) async {
    if (_isLoadingDetail) return;

    try {
      _isLoadingDetail = true;
      _detailError = null;
      notifyListeners();

      _selectedSermon = await _sermonService.getSermonById(sermonId);
      if (_selectedSermon != null) {
        _loadRelatedSermons(sermonId);
      }

      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _detailError = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // Load related sermons
  void _loadRelatedSermons(String currentSermonId) {
    _sermonService.getRelatedSermons(currentSermonId).listen(
      (sermons) {
        _relatedSermons = sermons;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading related sermons: $error');
      },
    );
  }

  // Clear selected sermon when leaving detail screen
  void clearSelectedSermon() {
    _selectedSermon = null;
    _relatedSermons = [];
    _detailError = null;
    _isLoadingDetail = false;
    notifyListeners();
  }

  // Method untuk refresh data
  Future<void> refreshSermons() async {
    _error = null;
    await loadSermons();
  }

  // Debug methods
  void debugPrintSermons() {
    print('Total sermons: ${_sermons.length}');
    for (var sermon in _sermons) {
      print('Sermon: ${sermon.title} - ${sermon.date}');
    }
  }

  void debugPrintSelectedSermon() {
    if (_selectedSermon != null) {
      print('Selected Sermon: ${_selectedSermon!.title}');
      print('Date: ${_selectedSermon!.formattedDate}');
    } else {
      print('No sermon selected');
    }
  }
}
