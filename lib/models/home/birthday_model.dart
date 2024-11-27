import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BirthdayModel {
  final String id;
  final String name;
  final String? photoUrl;
  final DateTime birthDate;
  final String userId;
  final DateTime createdAt;

  BirthdayModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.birthDate,
    required this.userId,
    required this.createdAt,
  });

  factory BirthdayModel.fromMap(String id, Map<String, dynamic> map) {
    // Parse birthDate dari string format "dd/MM/yyyy"
    final DateTime birthDate =
        DateFormat('dd/MM/yyyy').parse(map['birthDate'] ?? '');

    return BirthdayModel(
      id: id,
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      birthDate: birthDate,
      userId: map['userId'] ?? id, // Gunakan document ID jika userId kosong
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'birthDate':
          DateFormat('dd/MM/yyyy').format(birthDate), // Format ke string
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
