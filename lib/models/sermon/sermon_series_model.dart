import 'package:cloud_firestore/cloud_firestore.dart';

class SermonSeries {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SermonSeries({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory SermonSeries.fromMap(String id, Map<String, dynamic> map) {
    return SermonSeries(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
