import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  ProfileViewModel({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  bool _isLoading = true;
  UserModel? _userData;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  UserModel? get userData => _userData;
  String? get error => _error;

  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final isValidRole = await _authService.validateUserRole(user.uid);
      if (!isValidRole) {
        throw Exception('Invalid user role');
      }

      final userData = await _firestoreService.getUserData(user.uid);
      if (userData == null) {
        throw Exception('User data not found');
      }

      if (userData.role != 'user') {
        throw Exception('Invalid user role');
      }

      _userData = userData;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.logout();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
