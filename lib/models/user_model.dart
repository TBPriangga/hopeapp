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
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String role;
  final int? birthMonth; // 1-12
  final int? birthDay; // 1-31
  final bool isBaptized; // Status baptis
  final bool isChurchMember; // Status keanggotaan
  final String originChurch; // Asal gereja jika partisipan

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.address,
    this.birthDate,
    this.phoneNumber,
    this.photoUrl,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.role = 'user',
    this.birthMonth,
    this.birthDay,
    this.isBaptized = false,
    this.isChurchMember = true,
    this.originChurch = '',
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    final birthDate =
        map['birthDate'] != null && map['birthDate'].toString().isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(map['birthDate'])
            : null;

    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      address: map['address'],
      birthDate: birthDate,
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      role: map['role'] ?? 'user',
      birthMonth: birthDate?.month,
      birthDay: birthDate?.day,
      isBaptized: map['isBaptized'] ?? false,
      isChurchMember: map['isChurchMember'] ?? true,
      originChurch: map['originChurch'] ?? '',
    );
  }

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
      'fcmToken': fcmToken,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'birthMonth': birthDate?.month,
      'birthDay': birthDate?.day,
      'isBaptized': isBaptized,
      'isChurchMember': isChurchMember,
      'originChurch': originChurch,
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
    bool? isBaptized,
    bool? isChurchMember,
    String? originChurch,
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
      birthMonth: birthDate?.month ?? this.birthMonth,
      birthDay: birthDate?.day ?? this.birthDay,
      isBaptized: isBaptized ?? this.isBaptized,
      isChurchMember: isChurchMember ?? this.isChurchMember,
      originChurch: originChurch ?? this.originChurch,
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
        other.role == role &&
        other.isBaptized == isBaptized &&
        other.isChurchMember == isChurchMember &&
        other.originChurch == originChurch;
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
        role.hashCode ^
        isBaptized.hashCode ^
        isChurchMember.hashCode ^
        originChurch.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, isBaptized: $isBaptized, isChurchMember: $isChurchMember)';
  }
}
