import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/offering/offering_service.dart';
import '../../../models/offering/offering_report.dart';

class OfferingReportScreen extends StatefulWidget {
  const OfferingReportScreen({super.key});

  @override
  State<OfferingReportScreen> createState() => _OfferingReportScreenState();
}

class _OfferingReportScreenState extends State<OfferingReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF132054),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Persembahan Bulanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildReportList(),
    );
  }

  Widget _buildReportList() {
    return StreamBuilder<List<OfferingReport>>(
      stream: OfferingReportService().getReportsByType(ReportType.bulanan),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada laporan bulanan',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(OfferingReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewPdfReport(context, report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132054).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF132054),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132054),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laporan Bulanan',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.visibility,
                color: Color(0xFF132054),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method untuk melihat PDF langsung di app
  Future<void> _viewPdfReport(
      BuildContext context, OfferingReport report) async {
    try {
      // Tampilkan loading indicator
      _showLoadingDialog(context);

      // Buka PDF Viewer dengan URL dari report
      Navigator.pop(context); // Tutup dialog loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            pdfUrl: report.fileUrl,
            title: report.formattedDate,
          ),
        ),
      );
    } catch (e) {
      // Tutup dialog loading jika masih ditampilkan
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat PDF...'),
            ],
          ),
        ),
      ),
    );
  }
}

// Class untuk menampilkan PDF Viewer
class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF132054),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Tombol untuk download PDF jika diperlukan
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(
          child: CircularProgressIndicator(
            value: progress / 100,
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Gagal memuat PDF: $error',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method untuk download PDF jika user ingin menyimpannya
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      final dir = await getExternalStorageDirectory();
      final fileName = 'laporan_${title.replaceAll(' ', '_')}.pdf';
      final file = File('${dir!.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF berhasil diunduh ke: ${file.path}'),
            backgroundColor: const Color(0xFF132054),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
