import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/utils/youtube_helper.dart';
import '../../../models/sermon/sermon_model.dart';
import '../../../viewsModels/sermon/sermon_viewmodel.dart';

class DetailSermonScreen extends StatefulWidget {
  const DetailSermonScreen({super.key});

  @override
  State<DetailSermonScreen> createState() => _DetailSermonScreenState();
}

class _DetailSermonScreenState extends State<DetailSermonScreen> {
  String? _sermonId;
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;

  // Kontrol ukuran teks
  double _textScaleFactor = 1.0;
  static const double _minTextScale = 0.8;
  static const double _maxTextScale = 2.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sermonId == null) {
      _sermonId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_sermonId != null) {
        Future.microtask(() {
          final viewModel = context.read<SermonViewModel>();
          viewModel.loadSermonDetail(_sermonId!).then((_) {
            if (viewModel.selectedSermon?.youtubeUrl.isNotEmpty == true) {
              _initializeYoutubePlayer(viewModel.selectedSermon!.youtubeUrl);
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializeYoutubePlayer(String url) {
    if (url.isEmpty) return;
    try {
      setState(() {
        _youtubeController = YouTubeHelper.initializeController(url);
      });
    } catch (e) {
      print('Error initializing YouTube player: $e');
    }
  }

  Widget _buildMediaContent(SermonModel sermon) {
    if (sermon.youtubeUrl.isNotEmpty && _youtubeController != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF132054),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF132054),
            handleColor: Color(0xFF132054),
          ),
          onReady: () {
            setState(() {
              _isPlayerReady = true;
            });
          },
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          sermon.imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
          },
        ),
      );
    }
  }

  Widget _buildSummaryCard(SermonModel sermon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon dan judul ringkasan
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF132054),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132054),
                    ),
                  ),
                ],
              ),
              // Kontrol ukuran teks
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _textScaleFactor = (_textScaleFactor - 0.1)
                            .clamp(_minTextScale, _maxTextScale);
                      });
                    },
                    iconSize: 20,
                    color: Colors.grey[600],
                    tooltip: 'Perkecil teks',
                  ),
                  Text(
                    'Ukuran Teks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _textScaleFactor = (_textScaleFactor + 0.1)
                            .clamp(_minTextScale, _maxTextScale);
                      });
                    },
                    iconSize: 20,
                    color: Colors.grey[600],
                    tooltip: 'Perbesar teks',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sermon.description,
            style: TextStyle(
              fontSize: 15 * _textScaleFactor,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingDetail) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final sermon = viewModel.selectedSermon;
        if (sermon == null) {
          return const Scaffold(
            body: Center(child: Text('Khotbah tidak ditemukan')),
          );
        }

        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              viewModel.clearSelectedSermon();
            }
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: const Color(0xFF132054),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      viewModel.clearSelectedSermon();
                      Navigator.pop(context);
                    },
                  ),
                  centerTitle: true,
                  title: const Text(
                    'Khotbah',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMediaContent(sermon),
                        const SizedBox(height: 16),
                        if (viewModel.selectedSeries != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    viewModel.selectedSeries!.title,
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          sermon.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132054),
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    sermon.formattedDate,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.person_outline,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    sermon.preacher,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryCard(sermon),
                        if (sermon.materials.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Materi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF132054),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...sermon.materials.map((material) => Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: Icon(
                                    material.fileType?.toLowerCase() == 'pdf'
                                        ? Icons.picture_as_pdf
                                        : Icons.insert_drive_file,
                                    color: const Color(0xFF132054),
                                    size: 20,
                                  ),
                                  title: Text(
                                    material.title,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing:
                                      const Icon(Icons.download, size: 20),
                                  onTap: () {
                                    // Handle material download
                                  },
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
