import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SermonModel {
  final String id;
  final String title;
  final String seriesId;
  final DateTime date;
  final String imageUrl;
  final String youtubeUrl;
  final String preacher;
  final String description;
  final bool isActive;
  final List<SermonMaterial> materials;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SermonModel({
    required this.id,
    required this.title,
    required this.seriesId,
    required this.date,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.preacher,
    required this.description,
    this.isActive = true,
    this.materials = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // Getter untuk format tanggal normal
  String get formattedDate {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // Getter untuk format timeAgo
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 7) {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Getter untuk mengecek apakah memiliki video YouTube
  bool get hasVideo => youtubeUrl.isNotEmpty;

  // Getter untuk mendapatkan YouTube video ID
  String? get youtubeVideoId {
    if (!hasVideo) return null;

    // Handle format URL YouTube yang berbeda
    RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/');
    Match? match = regExp.firstMatch(youtubeUrl);

    return match?.group(7);
  }

  factory SermonModel.fromMap(String id, Map<String, dynamic> map) {
    return SermonModel(
      id: id,
      title: map['title'] ?? '',
      seriesId: map['seriesId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      preacher: map['preacher'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      materials: ((map['materials'] ?? []) as List)
          .map((material) =>
              SermonMaterial.fromMap(Map<String, dynamic>.from(material)))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'seriesId': seriesId,
      'date': date,
      'imageUrl': imageUrl,
      'youtubeUrl': youtubeUrl,
      'preacher': preacher,
      'description': description,
      'isActive': isActive,
      'materials': materials.map((material) => material.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class SermonMaterial {
  final String title;
  final String url;
  final String? fileType;

  SermonMaterial({
    required this.title,
    required this.url,
    this.fileType,
  });

  factory SermonMaterial.fromMap(Map<String, dynamic> map) {
    return SermonMaterial(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      fileType: map['fileType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'fileType': fileType,
    };
  }
}
