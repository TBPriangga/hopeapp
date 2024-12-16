import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/offering/offering_report.dart';

class OfferingReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OfferingReport>> getReportsByType(ReportType type) {
    return _firestore
        .collection('offering_reports')
        .where('reportType', isEqualTo: type.name)
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferingReport.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> downloadReport(OfferingReport report) async {
    try {
      final url = report.fileUrl;
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      throw Exception('Failed to download report: $e');
    }
  }
}
