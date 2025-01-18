import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth/auth_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!_validateInputs(oldPassword, newPassword, confirmPassword)) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool _validateInputs(
      String oldPassword, String newPassword, String confirmPassword) {
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _setError('Semua field harus diisi');
      return false;
    }

    if (newPassword.length < 6) {
      _setError('Password baru minimal 6 karakter');
      return false;
    }

    if (newPassword != confirmPassword) {
      _setError('Password baru tidak cocok');
      return false;
    }

    return true;
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Password lama tidak sesuai';
      case 'requires-recent-login':
        return 'Silakan logout dan login kembali untuk mengubah password';
      default:
        return 'Terjadi kesalahan: ${e.message}';
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

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
