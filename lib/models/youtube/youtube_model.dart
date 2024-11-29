class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final Thumbnail thumbnail;
  final bool isLive;
  final DateTime publishedAt;
  final String channelTitle;
  final String channelId;

  const YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.isLive,
    required this.publishedAt,
    required this.channelTitle,
    required this.channelId,
  });

  String get url => 'https://www.youtube.com/watch?v=$id';

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final videoId = json['id']['videoId'];

    return YouTubeVideo(
      id: videoId,
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnail: Thumbnail.fromJson(snippet['thumbnails']),
      isLive: snippet['liveBroadcastContent'] == 'live',
      publishedAt: DateTime.parse(snippet['publishedAt']),
      channelTitle: snippet['channelTitle'] ?? '',
      channelId: snippet['channelId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail.toJson(),
      'isLive': isLive,
      'publishedAt': publishedAt.toIso8601String(),
      'channelTitle': channelTitle,
      'channelId': channelId,
    };
  }
}

// youtube_thumbnail_model.dart
class Thumbnail {
  final String defaultUrl;
  final String mediumUrl;
  final String highUrl;
  final ThumbnailSize defaultSize;
  final ThumbnailSize mediumSize;
  final ThumbnailSize highSize;

  const Thumbnail({
    required this.defaultUrl,
    required this.mediumUrl,
    required this.highUrl,
    required this.defaultSize,
    required this.mediumSize,
    required this.highSize,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      defaultUrl: json['default']?['url'] ?? '',
      mediumUrl: json['medium']?['url'] ?? '',
      highUrl: json['high']?['url'] ?? '',
      defaultSize: ThumbnailSize(
        width: json['default']?['width'] ?? 0,
        height: json['default']?['height'] ?? 0,
      ),
      mediumSize: ThumbnailSize(
        width: json['medium']?['width'] ?? 0,
        height: json['medium']?['height'] ?? 0,
      ),
      highSize: ThumbnailSize(
        width: json['high']?['width'] ?? 0,
        height: json['high']?['height'] ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default': {
        'url': defaultUrl,
        'width': defaultSize.width,
        'height': defaultSize.height,
      },
      'medium': {
        'url': mediumUrl,
        'width': mediumSize.width,
        'height': mediumSize.height,
      },
      'high': {
        'url': highUrl,
        'width': highSize.width,
        'height': highSize.height,
      },
    };
  }

  String getUrlByQuality(ThumbnailQuality quality) {
    switch (quality) {
      case ThumbnailQuality.high:
        return highUrl;
      case ThumbnailQuality.medium:
        return mediumUrl;
      case ThumbnailQuality.low:
        return defaultUrl;
    }
  }

  ThumbnailSize getSizeByQuality(ThumbnailQuality quality) {
    switch (quality) {
      case ThumbnailQuality.high:
        return highSize;
      case ThumbnailQuality.medium:
        return mediumSize;
      case ThumbnailQuality.low:
        return defaultSize;
    }
  }
}

// youtube_thumbnail_size_model.dart
class ThumbnailSize {
  final int width;
  final int height;

  const ThumbnailSize({
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

// youtube_enums.dart
enum ThumbnailQuality {
  high,
  medium,
  low,
}

// youtube_response_model.dart
class YouTubeResponse {
  final String kind;
  final String etag;
  final PageInfo pageInfo;
  final List<YouTubeVideo> items;
  final String? nextPageToken;
  final String? prevPageToken;
  final String? regionCode;

  const YouTubeResponse({
    required this.kind,
    required this.etag,
    required this.pageInfo,
    required this.items,
    this.nextPageToken,
    this.prevPageToken,
    this.regionCode,
  });

  factory YouTubeResponse.fromJson(Map<String, dynamic> json) {
    return YouTubeResponse(
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      pageInfo: PageInfo.fromJson(json['pageInfo']),
      items: (json['items'] as List?)
              ?.map((item) => YouTubeVideo.fromJson(item))
              .toList() ??
          [],
      nextPageToken: json['nextPageToken'],
      prevPageToken: json['prevPageToken'],
      regionCode: json['regionCode'],
    );
  }
}

// youtube_page_info_model.dart
class PageInfo {
  final int totalResults;
  final int resultsPerPage;

  const PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      totalResults: json['totalResults'] ?? 0,
      resultsPerPage: json['resultsPerPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalResults': totalResults,
      'resultsPerPage': resultsPerPage,
    };
  }
}
