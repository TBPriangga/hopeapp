import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeHelper {
  // Extract YouTube video ID from various URL formats
  static String? extractVideoId(String url) {
    // Handle youtu.be format
    if (url.contains('youtu.be')) {
      return url.split('/').last.split('?').first;
    }

    // Handle live format
    if (url.contains('/live/')) {
      return url.split('/live/')[1].split('?').first;
    }

    // Handle watch?v= format
    if (url.contains('watch?v=')) {
      return url.split('watch?v=')[1].split('&').first;
    }

    return null;
  }

  // Initialize YouTube player controller with proper configuration
  static YoutubePlayerController initializeController(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) {
      throw Exception('Invalid YouTube URL');
    }

    return YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        hideControls: false,
        hideThumbnail: false,
      ),
    );
  }
}
