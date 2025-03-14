import 'package:flutter/material.dart';

class DiscipleshipClassModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String mentor;
  final String classPhotoUrl;
  final bool isActive;

  DiscipleshipClassModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.mentor,
    required this.classPhotoUrl,
    this.isActive = true,
  });

  // Helper untuk mendapatkan icon berdasarkan kategori
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'anak':
        return Icons.child_care;
      case 'remaja-pemuda':
        return Icons.groups;
      case 'dewasa muda':
        return Icons.person;
      case 'dewasa senior':
        return Icons.people_outline;
      default:
        return Icons.group;
    }
  }

  // Helper untuk mendapatkan warna berdasarkan kategori
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'anak':
        return Colors.blue;
      case 'remaja-pemuda':
        return Colors.orange;
      case 'dewasa muda':
        return Colors.green;
      case 'dewasa senior':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
