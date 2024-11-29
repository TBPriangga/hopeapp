import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/youtube/youtube_service.dart';
import '../../models/youtube/youtube_model.dart';

class YouTubeViewModel extends ChangeNotifier {
  final YouTubeService _youtubeService;

  List<YouTubeVideo> _liveVideos = [];
  List<YouTubeVideo> _uploadedVideos = [];
  Map<String, dynamic>? _channelInfo;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  List<YouTubeVideo> _searchResults = [];

  // Getters
  List<YouTubeVideo> get liveVideos => _liveVideos;
  List<YouTubeVideo> get uploadedVideos => _uploadedVideos;
  Map<String, dynamic>? get channelInfo => _channelInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<YouTubeVideo> get searchResults => _searchResults;
  bool get hasSearchQuery => _searchQuery != null && _searchQuery!.isNotEmpty;

  YouTubeViewModel({required YouTubeService youtubeService})
      : _youtubeService = youtubeService;

  Future<void> loadVideos() async {
    try {
      _setLoading(true);
      _error = null;

      // Load live streams and uploaded videos concurrently
      final results = await Future.wait([
        _youtubeService.fetchLiveStreams(),
        _youtubeService.fetchUploadedVideos(),
        _youtubeService.getChannelInfo(),
      ]);

      _liveVideos = results[0] as List<YouTubeVideo>;
      _uploadedVideos = results[1] as List<YouTubeVideo>;
      _channelInfo = results[2] as Map<String, dynamic>;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> refreshVideos() async {
    _error = null;
    await loadVideos();
  }

  Future<void> searchVideos(String query) async {
    if (query.isEmpty) {
      _searchQuery = null;
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _error = null;
      _searchQuery = query;

      _searchResults = await _youtubeService.searchVideos(query);

      _setLoading(false);
    } catch (e) {
      _setError('Error searching videos: $e');
    }
  }

  Future<void> clearSearch() async {
    _searchQuery = null;
    _searchResults = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getVideoStats(String videoId) async {
    try {
      return await _youtubeService.getVideoStats(videoId);
    } catch (e) {
      _setError('Error fetching video stats: $e');
      return null;
    }
  }

  Future<void> launchYouTubeChannel() async {
    final url = Uri.parse(_youtubeService.getChannelUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _setError('Could not launch YouTube channel');
    }
  }

  Future<void> openVideo(String videoUrl) async {
    final url = Uri.parse(videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _setError('Could not open video');
    }
  }

  String getFormattedStatCount(String? count) {
    if (count == null) return '0';
    final number = int.tryParse(count) ?? 0;
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
