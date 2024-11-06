import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String address;
  final DateTime birthDate;
  final String phoneNumber;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.address,
    required this.birthDate,
    required this.phoneNumber,
    this.createdAt,
  });

  // Konversi dari Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      birthDate: (map['birthDate'] as String).isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(map['birthDate'])
          : DateTime.now(), // atau nilai default lain
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'address': address,
      'birthDate':
          DateFormat('dd/MM/yyyy').format(birthDate), // Format ke string
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
