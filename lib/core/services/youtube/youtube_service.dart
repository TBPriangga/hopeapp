import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/youtube/youtube_model.dart';
import '../../config/env.dart';

class YouTubeService {
  final String _apiKey = Env.youtubeApiKey;
  final String _channelId = Env.youtubeChannelId;

  Future<List<YouTubeVideo>> fetchLiveStreams() async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&channelId=$_channelId&type=video&'
        'eventType=live&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => YouTubeVideo.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load live streams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching live streams: $e');
    }
  }

  Future<List<YouTubeVideo>> fetchUploadedVideos({int maxResults = 50}) async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&channelId=$_channelId&type=video&'
        'order=date&maxResults=$maxResults&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => YouTubeVideo.fromJson(item))
            .toList()
            .where((video) => !video.isLive)
            .toList();
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  String getChannelUrl() {
    return 'https://www.youtube.com/@gerejabaptisindonesiapengh8245';
  }

  Future<Map<String, dynamic>> getChannelInfo() async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/channels?'
        'part=snippet,statistics&id=$_channelId&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final channelData = data['items'][0];
          return {
            'title': channelData['snippet']['title'],
            'description': channelData['snippet']['description'],
            'thumbnailUrl': channelData['snippet']['thumbnails']['default']
                ['url'],
            'subscriberCount': channelData['statistics']['subscriberCount'],
            'videoCount': channelData['statistics']['videoCount'],
            'viewCount': channelData['statistics']['viewCount'],
          };
        }
        throw Exception('Channel not found');
      } else {
        throw Exception('Failed to load channel info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching channel info: $e');
    }
  }

  Future<List<YouTubeVideo>> searchVideos(String query) async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/search?'
        'part=snippet&channelId=$_channelId&type=video&'
        'q=${Uri.encodeComponent(query)}&maxResults=20&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => YouTubeVideo.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }

  Future<Map<String, dynamic>> getVideoStats(String videoId) async {
    final url = Uri.parse('https://www.googleapis.com/youtube/v3/videos?'
        'part=statistics&id=$videoId&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0]['statistics'];
        }
        throw Exception('Video not found');
      } else {
        throw Exception('Failed to load video stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching video stats: $e');
    }
  }
}
