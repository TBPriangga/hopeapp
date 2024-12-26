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

      // Update FCM Token
      await _updateFCMToken(userCredential.user!.uid);

      // Subscribe to topics
      await _subscribeToTopics();

      // Set current user
      _currentUser = userData;

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

      // Validasi role
      if (!await _authService.validateUserRole(userCredential.user!.uid)) {
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      final user = userCredential.user!;
      final bool isNewUser = await _authService.isNewUser(user.uid);

      // Update FCM Token
      await _updateFCMToken(user.uid);

      if (isNewUser) {
        // Subscribe to topics for new user
        await _subscribeToTopics();

        return {
          'success': true,
          'isNewUser': true,
          'userData': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'role': 'user',
          }
        };
      } else {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData == null) {
          throw Exception('User data not found');
        }

        if (userData.role != 'user') {
          throw Exception('Invalid user role');
        }

        // Subscribe to topics for existing user
        await _subscribeToTopics();

        _currentUser = userData;

        return {'success': true, 'isNewUser': false, 'userData': userData};
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return {'success': false, 'error': _errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateFCMToken(String userId) async {
    try {
      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the token
        String? token = await _firebaseMessaging.getToken();

        if (token != null) {
          // Save the token to Firestore menggunakan method yang ada
          await _firestoreService.saveUserData(
            UserModel(
              id: userId,
              email: _currentUser?.email ?? '',
              name: _currentUser?.name ?? '',
              fcmToken: token, // Tambahkan field ini di UserModel
              role: _currentUser?.role ?? 'user',
              updatedAt: DateTime.now(),
            ),
          );

          print('FCM Token updated for user: $userId');
        }
      }
    } catch (e) {
      print('Error updating FCM token: $e');
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
