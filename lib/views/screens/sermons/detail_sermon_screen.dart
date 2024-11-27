import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewsModels/sermon/sermon_viewmodel.dart';

class DetailSermonScreen extends StatefulWidget {
  const DetailSermonScreen({super.key});

  @override
  State<DetailSermonScreen> createState() => _DetailSermonScreenState();
}

class _DetailSermonScreenState extends State<DetailSermonScreen> {
  String? _sermonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sermonId == null) {
      _sermonId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_sermonId != null) {
        Future.microtask(
            () => context.read<SermonViewModel>().loadSermonDetail(_sermonId!));
      }
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

        if (viewModel.detailError != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.detailError}'),
                  ElevatedButton(
                    onPressed: () {
                      if (_sermonId != null) {
                        viewModel.loadSermonDetail(_sermonId!);
                      }
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
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
            appBar: AppBar(
              backgroundColor: const Color(0xFF132054),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  viewModel.clearSelectedSermon();
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Sermon',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              actions: const [
                IconButton(
                  icon:
                      Icon(Icons.bookmark_border_outlined, color: Colors.white),
                  onPressed: null,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              sermon.formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sermon.timeAgo,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 8),
                            const Icon(Icons.bookmark_border, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Image.network(
                    sermon.imageDetailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembicara: ${sermon.preacher}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          sermon.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (viewModel.relatedSermons.isNotEmpty) ...[
                          const Text(
                            'Sermon Lainnya',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.relatedSermons.length,
                              itemBuilder: (context, index) {
                                final relatedSermon =
                                    viewModel.relatedSermons[index];
                                return GestureDetector(
                                  onTap: () {
                                    viewModel
                                        .loadSermonDetail(relatedSermon.id);
                                  },
                                  child: Container(
                                    width: 300,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            relatedSermon.imageDetailUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                bottom: Radius.circular(8),
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                  Colors.black.withOpacity(0.8),
                                                ],
                                                stops: const [0.0, 0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                relatedSermon.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
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
                              },
                            ),
                          ),
                        ],
                      ],
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
}
