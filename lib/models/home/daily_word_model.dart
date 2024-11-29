import 'package:cloud_firestore/cloud_firestore.dart';

class DailyWordModel {
  final String id;
  final String verse;
  final String content;
  final String description;
  final String bibleUrl;
  final DateTime date;
  final bool isActive;

  DailyWordModel({
    required this.id,
    required this.verse,
    required this.content,
    required this.description,
    required this.bibleUrl,
    required this.date,
    this.isActive = true,
  });

  factory DailyWordModel.fromMap(String id, Map<String, dynamic> map) {
    return DailyWordModel(
      id: id,
      verse: map['verse'] ?? '',
      content: map['content'] ?? '',
      description: map['description'] ?? '',
      bibleUrl: map['bibleUrl'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
}
