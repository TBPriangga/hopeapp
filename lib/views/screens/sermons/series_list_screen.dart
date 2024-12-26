import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewsModels/sermon/sermon_viewmodel.dart';
import '../../../models/sermon/sermon_series_model.dart';
import '../../../app/routes/app_routes.dart';

class SermonSeriesScreen extends StatefulWidget {
  const SermonSeriesScreen({super.key});

  @override
  State<SermonSeriesScreen> createState() => _SermonSeriesScreenState();
}

class _SermonSeriesScreenState extends State<SermonSeriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load series when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonViewModel>().loadSermonSeries();
    });
  }

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
          'Series Khotbah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SermonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingSeries) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.seriesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.seriesError}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadSermonSeries(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132054),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final series = viewModel.sermonSeries;
          if (series.isEmpty) {
            return const Center(
              child: Text('Tidak ada series khotbah tersedia'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: series.length,
              itemBuilder: (context, index) {
                return _buildSeriesCard(context, series[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeriesCard(BuildContext context, SermonSeries series) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.sermonSeries,
            arguments: series.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Series Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                series.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
            // Series Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132054),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
