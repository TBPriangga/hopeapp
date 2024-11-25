import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Login dengan Firebase Auth
      UserCredential userCredential = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Get user data dari Firestore
      final userData =
          await _firestoreService.getUserData(userCredential.user!.uid);
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Set current user
      _currentUser = userData;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Method untuk logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to logout: $e';
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = 'Email dan password harus diisi';
      notifyListeners();
      return false;
    }

    // Validasi format email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential? userCredential =
          await _authService.signInWithGoogle();

      if (userCredential == null) {
        throw Exception('Google sign in cancelled');
      }

      final User user = userCredential.user!;
      final bool isNewUser = await _authService.isNewUser(user.uid);

      if (isNewUser) {
        // User baru perlu melengkapi profile
        return {
          'success': true,
          'isNewUser': true,
          'userData': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
          }
        };
      } else {
        // User yang sudah ada
        final userData = await _firestoreService.getUserData(user.uid);

        // Update photo URL jika berubah
        if (userData != null &&
            user.photoURL != null &&
            user.photoURL != userData.photoUrl) {
          final updatedUser = userData.copyWith(photoUrl: user.photoURL);
          await _firestoreService.saveUserData(updatedUser);
          _currentUser = updatedUser;
        } else {
          _currentUser = userData;
        }

        if (_currentUser == null) {
          throw Exception('User data not found');
        }

        return {'success': true, 'isNewUser': false, 'userData': _currentUser};
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return {'success': false, 'error': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        case 'account-exists-with-different-credential':
          return 'Akun sudah terdaftar dengan metode login yang berbeda';
        case 'invalid-credential':
          return 'Kredensial tidak valid';
        case 'operation-not-allowed':
          return 'Login dengan Google tidak diizinkan';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return 'Terjadi kesalahan: $e';
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
