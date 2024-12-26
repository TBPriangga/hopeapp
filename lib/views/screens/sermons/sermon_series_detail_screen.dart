import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewsModels/sermon/sermon_viewmodel.dart';
import '../../../models/sermon/sermon_model.dart';
import '../../../app/routes/app_routes.dart';

class SermonSeriesDetailScreen extends StatefulWidget {
  const SermonSeriesDetailScreen({super.key});

  @override
  State<SermonSeriesDetailScreen> createState() =>
      _SermonSeriesDetailScreenState();
}

class _SermonSeriesDetailScreenState extends State<SermonSeriesDetailScreen> {
  String? _seriesId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seriesId == null) {
      _seriesId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_seriesId != null) {
        Future.microtask(() => _initializeSeries());
      }
    }
  }

  Future<void> _initializeSeries() async {
    try {
      final viewModel = context.read<SermonViewModel>();

      if (viewModel.sermonSeries.isEmpty) {
        await viewModel.loadSermonSeries();
      }

      final series = viewModel.sermonSeries.firstWhere(
        (series) => series.id == _seriesId,
        orElse: () => throw Exception('Series not found'),
      );

      await viewModel.loadSermonsBySeries(series.id);
      viewModel.setSelectedSeries(series);
    } catch (e) {
      print('Error initializing series: $e');
    }
  }

  Widget _buildSermonsList(SermonViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_seriesId != null) {
                  viewModel.loadSermonsBySeries(_seriesId!);
                }
              },
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

    final sermons = viewModel.sermons;
    if (sermons.isEmpty) {
      return const Center(
        child: Text('Tidak ada khotbah dalam series ini'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sermons.length,
      itemBuilder: (context, index) {
        return _buildSermonCard(context, sermons[index]);
      },
    );
  }

  Widget _buildSermonCard(BuildContext context, SermonModel sermon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.detailSermon,
            arguments: sermon.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Sermon Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  sermon.imageUrl,
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Sermon Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sermon.formattedDate,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sermon.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sermon.preacher,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonViewModel>(
      builder: (context, viewModel, child) {
        final selectedSeries = viewModel.selectedSeries;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: const Color(0xFF132054),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              selectedSeries?.title ?? 'Series Detail',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Series Header
              if (selectedSeries != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF132054),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedSeries.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedSeries.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              // Sermons List
              Expanded(
                child: _buildSermonsList(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }
}
