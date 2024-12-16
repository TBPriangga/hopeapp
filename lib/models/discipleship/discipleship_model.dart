import 'package:flutter/material.dart';

class DiscipleshipClassModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String schedule;
  final String mentor;
  final String mentorPhoto;
  final String location;
  final bool isActive;

  DiscipleshipClassModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.schedule,
    required this.mentor,
    required this.mentorPhoto,
    required this.location,
    this.isActive = true,
  });

  // Helper untuk mendapatkan icon berdasarkan kategori
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'anak-anak':
        return Icons.child_care;
      case 'remaja':
        return Icons.face;
      case 'pemuda':
        return Icons.group;
      case 'pemudi':
        return Icons.group;
      case 'dewasa pria':
        return Icons.man;
      case 'dewasa wanita':
        return Icons.woman;
      default:
        return Icons.group;
    }
  }

  // Helper untuk mendapatkan warna berdasarkan kategori
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'anak-anak':
        return Colors.blue;
      case 'remaja':
        return Colors.green;
      case 'pemuda':
        return Colors.orange;
      case 'pemudi':
        return Colors.pink;
      case 'dewasa pria':
        return Colors.indigo;
      case 'dewasa wanita':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
