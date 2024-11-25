import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? address;
  final DateTime? birthDate;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.address,
    this.birthDate,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
  });

  // Konversi dari Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      address: map['address'],
      birthDate:
          map['birthDate'] != null && map['birthDate'].toString().isNotEmpty
              ? DateFormat('dd/MM/yyyy').parse(map['birthDate'])
              : null,
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt']?.toDate(),
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'address': address,
      'birthDate': birthDate != null
          ? DateFormat('dd/MM/yyyy').format(birthDate!)
          : null,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper method untuk update data
  UserModel copyWith({
    String? email,
    String? name,
    String? address,
    DateTime? birthDate,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return UserModel(
      id: this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: this.createdAt,
    );
  }
}
