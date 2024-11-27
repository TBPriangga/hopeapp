import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String imageUrl;
  final String imageDetailUrl;
  final String description;
  final Speaker? speaker;
  final List<EventMaterial> materials;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.imageDetailUrl,
    required this.description,
    this.speaker,
    this.materials = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Getter untuk format tanggal di card
  String get formattedDate {
    return '${DateFormat('EEEE, dd MMM • HH:mm', 'id_ID').format(date)} WIB';
  }

  // Getter untuk format tanggal di detail
  String get formattedDetailDate {
    return '${DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(date)} WIB';
  }

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageDetailUrl: map['imageDetailUrl'] ??
          map['imageUrl'] ??
          '', // Fallback ke imageUrl jika detail tidak ada
      description: map['description'] ?? '',
      speaker: map['speaker'] != null ? Speaker.fromMap(map['speaker']) : null,
      materials: (map['materials'] as List<dynamic>? ?? [])
          .map((material) => EventMaterial.fromMap(material))
          .toList(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
      'imageDetailUrl': imageDetailUrl,
      'description': description,
      'speaker': speaker?.toMap(),
      'materials': materials.map((material) => material.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class Speaker {
  final String name;
  final String role;
  final String? imageUrl;

  Speaker({
    required this.name,
    required this.role,
    this.imageUrl,
  });

  factory Speaker.fromMap(Map<String, dynamic> map) {
    return Speaker(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}

class EventMaterial {
  final String title;
  final String url;
  final String? fileType;
  final int? fileSize; // in bytes

  EventMaterial({
    required this.title,
    required this.url,
    this.fileType,
    this.fileSize,
  });

  factory EventMaterial.fromMap(Map<String, dynamic> map) {
    return EventMaterial(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      fileType: map['fileType'],
      fileSize: map['fileSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'fileType': fileType,
      'fileSize': fileSize,
    };
  }

  // Helper method untuk format ukuran file
  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
