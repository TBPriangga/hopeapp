import 'package:flutter/material.dart';
import '../../../core/services/offering/offering_service.dart';
import '../../../models/offering/offering_report.dart';

class OfferingReportViewModel extends ChangeNotifier {
  final OfferingReportService _offeringReportService = OfferingReportService();

  ReportType _currentReportType = ReportType.bulanan;
  bool _isLoading = false;
  String? _error;

  // Getters
  ReportType get currentReportType => _currentReportType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setter untuk mengubah tipe laporan
  void setReportType(ReportType type) {
    if (_currentReportType != type) {
      _currentReportType = type;
      notifyListeners();
    }
  }

  // Mendapatkan stream laporan berdasarkan tipe
  Stream<List<OfferingReport>> getReportsByType(ReportType type) {
    return _offeringReportService.getReportsByType(type);
  }

  // Download report
  Future<void> downloadReport(OfferingReport report) async {
    try {
      _setLoading(true);
      await _offeringReportService.downloadReport(report);
      _setLoading(false);
    } catch (e) {
      _setError('Gagal mengunduh laporan: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
