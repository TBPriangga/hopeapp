import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan data user saat register
  Future<void> saveUserData(UserModel user) async {
    try {
      // Validasi data sebelum disimpan
      if (user.name.isEmpty || user.email.isEmpty) {
        throw Exception('Name and email are required');
      }

      await _firestore.collection('users').doc(user.id).set(
        {
          ...user.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  Future<void> updateUserFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(userId).get();
      return doc.exists &&
          (doc.data() as Map<String, dynamic>)['status'] == 'active';
    } catch (e) {
      return false;
    }
  }
}
