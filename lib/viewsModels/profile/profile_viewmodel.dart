import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isOfflineMode = false;
  String _appVersion = '';

  // Getters
  bool get isLoading => _isLoading;
  UserModel? get userData => _userData;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;
  String get appVersion => _appVersion;

  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      _setError(null);

      // Muat informasi versi aplikasi
      await _loadAppVersion();

      // Periksa koneksi internet
      final hasInternet = await _authService.checkInternetConnection();
      _isOfflineMode = !hasInternet;

      // Jika offline, coba load dari cache
      if (_isOfflineMode) {
        await _loadUserDataFromCache();
        return;
      }

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

      // Simpan ke cache
      await _saveUserDataToCache(userData);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Metode untuk muat informasi versi aplikasi
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion =
          packageInfo.version; // Tampilkan hanya versi tanpa build number
      notifyListeners();
    } catch (e) {
      print('Error loading app version: $e');
      _appVersion = 'Unknown Version';
    }
  }

  // Metode untuk menyimpan data ke cache
  Future<void> _saveUserDataToCache(UserModel userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_id', userData.id);
      await prefs.setString('cached_user_name', userData.name);
      await prefs.setString('cached_user_email', userData.email);
      await prefs.setString('cached_user_photo', userData.photoUrl ?? '');
      await prefs.setString('cached_user_phone', userData.phoneNumber ?? '');
      // Tambahkan field lain yang dibutuhkan
    } catch (e) {
      print('Error saving user data to cache: $e');
    }
  }

  // Metode untuk memuat data dari cache
  Future<void> _loadUserDataFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('cached_user_id');
      final name = prefs.getString('cached_user_name');
      final email = prefs.getString('cached_user_email');

      if (id == null || name == null || email == null) {
        throw Exception('No cached user data found');
      }

      _userData = UserModel(
        id: id,
        name: name,
        email: email,
        photoUrl: prefs.getString('cached_user_photo'),
        phoneNumber: prefs.getString('cached_user_phone'),
        // Tambahkan field lain sesuai kebutuhan
      );

      _setError('Menggunakan data offline');
    } catch (e) {
      _setError('Tidak dapat memuat data: $e');
    }
  }

  // Improved logout method
  Future<bool> logout() async {
    try {
      _setLoading(true);
      _setError(null);

      // Cek koneksi internet
      final hasInternet = await _authService.checkInternetConnection();

      // Hapus cache data user
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_user_id');
        await prefs.remove('cached_user_name');
        await prefs.remove('cached_user_email');
        await prefs.remove('cached_user_photo');
        await prefs.remove('cached_user_phone');
        // Hapus field cache lainnya jika ada
      } catch (e) {
        print('Error clearing user cache: $e');
      }

      if (!hasInternet) {
        // Jika tidak ada internet, hanya bersihkan state lokal
        // dan kembalikan flag untuk navigasi
        _userData = null;
        _setLoading(false);
        return true;
      }

      // Jika ada internet, lakukan full logout
      await _authService.logout(clearAll: true);

      _userData = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal logout: ${e.toString()}');
      _setLoading(false);
      return false;
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

  // Clear specific error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
