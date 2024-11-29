import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewsModels/youtube/youtube_viewmodel.dart';
import '../../widgets/youtube_video_card.dart';

class YouTubeScreen extends StatefulWidget {
  const YouTubeScreen({super.key});

  @override
  State<YouTubeScreen> createState() => _YouTubeScreenState();
}

class _YouTubeScreenState extends State<YouTubeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load videos when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YouTubeViewModel>().loadVideos();
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
          'GBI Pengharapan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: () =>
                context.read<YouTubeViewModel>().launchYouTubeChannel(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.live_tv, color: Colors.white),
              text: 'Live Streaming',
            ),
            Tab(
              icon: Icon(Icons.video_library, color: Colors.white),
              text: 'Video',
            ),
          ],
        ),
      ),
      body: Consumer<YouTubeViewModel>(
        builder: (context, viewModel, child) {
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
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadVideos(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132054),
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Live Streaming Tab
              _buildLiveStreamingTab(viewModel),

              // Video Tab
              _buildVideoTab(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLiveStreamingTab(YouTubeViewModel viewModel) {
    if (viewModel.liveVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada live streaming saat ini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.liveVideos.length,
      itemBuilder: (context, index) {
        return YouTubeVideoCard(
          video: viewModel.liveVideos[index],
          onTap: (url) => viewModel.openVideo(url),
        );
      },
    );
  }

  Widget _buildVideoTab(YouTubeViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.uploadedVideos.length,
      itemBuilder: (context, index) {
        return YouTubeVideoCard(
          video: viewModel.uploadedVideos[index],
          onTap: (url) => viewModel.openVideo(url),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
