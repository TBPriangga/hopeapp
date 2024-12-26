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
      return Image.network(
        sermon.imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    }
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
                // App Bar with back button
                SliverAppBar(
                  floating: true,
                  backgroundColor: const Color(0xFF132054),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      viewModel.clearSelectedSermon();
                      Navigator.pop(context);
                    },
                  ),
                  centerTitle: true,
                  title: Text(
                    'Sermon',
                    style: const TextStyle(
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
                        // YouTube Player or Thumbnail
                        _buildMediaContent(sermon),

                        const SizedBox(height: 16),

                        // Series info if available
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
                            child: Text(
                              viewModel.selectedSeries!.title,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Sermon title
                        Text(
                          sermon.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132054),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Date and preacher
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              sermon.formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.person_outline,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              sermon.preacher,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132054),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sermon.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Materials if available
                        if (sermon.materials.isNotEmpty) ...[
                          const Text(
                            'Materi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF132054),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Material cards
                          ...sermon.materials.map((material) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    material.fileType?.toLowerCase() == 'pdf'
                                        ? Icons.picture_as_pdf
                                        : Icons.insert_drive_file,
                                    color: const Color(0xFF132054),
                                  ),
                                  title: Text(material.title),
                                  trailing: const Icon(Icons.download),
                                  onTap: () {
                                    // Handle material download
                                  },
                                ),
                              )),
                        ],

                        const SizedBox(height: 24),

                        // Related sermons section
                        if (viewModel.relatedSermons.isNotEmpty) ...[
                          const Text(
                            'Khotbah Terkait',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF132054),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.relatedSermons.length,
                              itemBuilder: (context, index) {
                                final relatedSermon =
                                    viewModel.relatedSermons[index];
                                return _buildRelatedSermonCard(
                                    context, relatedSermon);
                              },
                            ),
                          ),
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

  Widget _buildRelatedSermonCard(BuildContext context, SermonModel sermon) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              '/detail-sermon',
              arguments: sermon.id,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  sermon.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sermon.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sermon.formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
