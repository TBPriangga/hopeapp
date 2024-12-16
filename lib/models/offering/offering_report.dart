import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ReportType { mingguan, bulanan, tahunan }

class OfferingReport {
  final String id;
  final ReportType reportType;
  final DateTime date;
  final String fileUrl;
  final String fileName;
  final bool isActive;

  OfferingReport({
    required this.id,
    required this.reportType,
    required this.date,
    required this.fileUrl,
    required this.fileName,
    this.isActive = true,
  });

  String get formattedDate {
    switch (reportType) {
      case ReportType.mingguan:
        return 'Minggu ${date.day ~/ 7 + 1}, ${DateFormat('MMMM yyyy', 'id_ID').format(date)}';
      case ReportType.bulanan:
        return DateFormat('MMMM yyyy', 'id_ID').format(date);
      case ReportType.tahunan:
        return DateFormat('yyyy', 'id_ID').format(date);
    }
  }

  String get reportTypeLabel {
    switch (reportType) {
      case ReportType.mingguan:
        return 'Laporan Mingguan';
      case ReportType.bulanan:
        return 'Laporan Bulanan';
      case ReportType.tahunan:
        return 'Laporan Tahunan';
    }
  }

  factory OfferingReport.fromMap(String id, Map<String, dynamic> map) {
    return OfferingReport(
      id: id,
      reportType: _stringToReportType(map['reportType']),
      date: (map['date'] as Timestamp).toDate(),
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  static ReportType _stringToReportType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mingguan':
        return ReportType.mingguan;
      case 'bulanan':
        return ReportType.bulanan;
      case 'tahunan':
        return ReportType.tahunan;
      default:
        return ReportType.mingguan;
    }
  }
}
