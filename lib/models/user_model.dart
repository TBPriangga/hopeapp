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
  final DateTime? updatedAt;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.address,
    this.birthDate,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.role = 'user',
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
      updatedAt: map['updatedAt']?.toDate(),
      role: map['role'] ?? 'user',
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
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
    String? role,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  // Helper method untuk check role
  bool get isUser => role == 'user';
  bool get isAdmin => role == 'admin';

  // Helper method untuk format tanggal
  String get formattedBirthDate {
    if (birthDate == null) return '';
    return DateFormat('dd/MM/yyyy').format(birthDate!);
  }

  // Helper method untuk validasi data
  bool get isValidUser {
    return email.isNotEmpty &&
        name.isNotEmpty &&
        (phoneNumber == null || phoneNumber!.length <= 15);
  }

  // Helper method untuk compare users
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.address == address &&
        other.birthDate == birthDate &&
        other.phoneNumber == phoneNumber &&
        other.photoUrl == photoUrl &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        address.hashCode ^
        birthDate.hashCode ^
        phoneNumber.hashCode ^
        photoUrl.hashCode ^
        role.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
