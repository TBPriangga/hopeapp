import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewsModels/sermon/sermon_viewmodel.dart';
import '../../../models/sermon/sermon_model.dart';
import '../../../app/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SermonSeriesDetailScreen extends StatefulWidget {
  const SermonSeriesDetailScreen({super.key});

  @override
  State<SermonSeriesDetailScreen> createState() =>
      _SermonSeriesDetailScreenState();
}

class _SermonSeriesDetailScreenState extends State<SermonSeriesDetailScreen> {
  String? _seriesId;
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonViewModel>(
      builder: (context, viewModel, child) {
        final selectedSeries = viewModel.selectedSeries;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF132054),
                  const Color(0xFF2B478A).withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Flexible App Bar with Series Image
                  SliverAppBar(
                    expandedHeight: 200, // Tinggi sesuai rasio 16:9
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: selectedSeries != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background Image dengan rasio 16:9
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: selectedSeries.imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: const Color(0xFF132054),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white60,
                                        size: 60,
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFF2B478A),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: const Color(0xFF132054),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Series Description dengan judul di atas
                  if (selectedSeries != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Series - DIPINDAH KE SINI
                            Text(
                              selectedSeries.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Series Metadata Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        selectedSeries.startDate != null
                                            ? DateFormat('MMM yyyy').format(
                                                selectedSeries.startDate!)
                                            : 'Ongoing',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.menu_book,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${viewModel.sermons.length} Khotbah',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Series Description
                            Text(
                              selectedSeries.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sermons Title
                            const Text(
                              'Khotbah dalam Series Ini',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Sermons List
                  viewModel.isLoading
                      ? const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : viewModel.error != null
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[300],
                                      size: 60,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: ${viewModel.error}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (_seriesId != null) {
                                          viewModel
                                              .loadSermonsBySeries(_seriesId!);
                                        }
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Coba Lagi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF132054),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : viewModel.sermons.isEmpty
                              ? const SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'Tidak ada khotbah dalam series ini',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildSermonCard(
                                          context, viewModel.sermons[index]),
                                      childCount: viewModel.sermons.length,
                                    ),
                                  ),
                                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSermonCard(BuildContext context, SermonModel sermon) {
    final bool hasVideo =
        sermon.youtubeUrl != null && sermon.youtubeUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.detailSermon,
              arguments: sermon.id,
            );
          },
          borderRadius: BorderRadius.circular(16),
          highlightColor: Colors.white.withOpacity(0.1),
          splashColor: Colors.white.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail dengan rasio 16:9 di bagian atas
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: sermon.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Play button overlay jika ada video
                  if (hasVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Color(0xFF132054),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Informasi khotbah di bagian bawah
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sermon.formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Judul
                    Text(
                      sermon.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Pendeta
                    Text(
                      sermon.preacher,
                      style: const TextStyle(
                        color: Colors.white70,
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
}
