import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  Future<bool> login() async {
    if (!_validateInputs()) return false;

    try {
      _setLoading(true);

      // Login dengan Firebase Auth
      UserCredential userCredential = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Validasi role
      if (!await _authService.validateUserRole(userCredential.user!.uid)) {
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      // Get user data dari Firestore
      final userData =
          await _firestoreService.getUserData(userCredential.user!.uid);
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Validasi tambahan untuk role
      if (userData.role != 'user') {
        throw Exception('Invalid user role');
      }

      // Set current user
      _currentUser = userData;

      // Update FCM Token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestoreService.updateUserFCMToken(
            userCredential.user!.uid, fcmToken);
      }

      // Subscribe to topics
      await _subscribeToTopics();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _setLoading(true);

      final UserCredential? userCredential =
          await _authService.signInWithGoogle();
      if (userCredential == null) {
        throw Exception('Google sign in cancelled');
      }

      final user = userCredential.user!;

      // Validasi role
      if (!await _authService.validateUserRole(user.uid)) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      final bool isNewUser = await _authService.isNewUser(user.uid);
      // Get FCM Token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('Error getting FCM token: $e');
      }

      if (isNewUser) {
        try {
          // Data untuk user baru dengan format yang sama seperti register biasa
          final Map<String, dynamic> userData = {
            'id': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'photoUrl': user.photoURL,
            'fcmToken': fcmToken,
            'role': 'user',
            'birthDate': '',
            'birthMonth': null,
            'birthDay': null,
            'phoneNumber': '',
            'address': '',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          };

          // Save user data
          await _firestoreService
              .saveUserData(UserModel.fromMap(user.uid, userData));
          await _subscribeToTopics();

          return {'success': true, 'isNewUser': true, 'userData': userData};
        } catch (e) {
          await FirebaseAuth.instance.signOut();
          print('Error saving new user data: $e');
          throw Exception('Failed to save user data');
        }
      } else {
        try {
          final userData = await _firestoreService.getUserData(user.uid);
          if (userData == null) {
            await FirebaseAuth.instance.signOut();
            throw Exception('User data not found');
          }

          if (userData.role != 'user') {
            await FirebaseAuth.instance.signOut();
            throw Exception('Invalid user role');
          }

          // Update FCM token if available
          if (fcmToken != null) {
            await _firestoreService.updateUserFCMToken(user.uid, fcmToken);
          }

          await _subscribeToTopics();
          _currentUser = userData;

          return {'success': true, 'isNewUser': false, 'userData': userData};
        } catch (e) {
          await FirebaseAuth.instance.signOut();
          print('Error processing existing user: $e');
          throw Exception('Failed to process user data');
        }
      }
    } catch (e) {
      print('SignInWithGoogle error: $e');
      await FirebaseAuth.instance.signOut();
      _setError(e.toString());
      return {'success': false, 'error': _errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      // Subscribe to general topics
      await _firebaseMessaging.subscribeToTopic('announcements');
      await _firebaseMessaging.subscribeToTopic('events');
      await _firebaseMessaging.subscribeToTopic('general');

      print('Subscribed to general topics');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _setError('Email dan password harus diisi');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _setError('Format email tidak valid');
      return false;
    }

    return true;
  }

  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return e.toString();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetForm() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
