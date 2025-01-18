import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Default avatar
  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;

  // Update tanggal
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  Future<bool> register() async {
    if (!_validateInputs()) return false;

    try {
      _setLoading(true);

      // Register dengan Firebase Auth
      UserCredential userCredential = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Get FCM Token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // Buat user model dengan role user
      final user = UserModel(
        id: userCredential.user!.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate!,
        phoneNumber: phoneController.text.trim(),
        photoUrl: defaultAvatarUrl,
        fcmToken: fcmToken, // Tambahkan FCM token
        role: 'user',
        createdAt: DateTime.now(),
      );

      // Simpan data user ke Firestore
      await _firestoreService.saveUserData(user);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e));
      return false;
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
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        addressController.text.isEmpty ||
        _selectedDate == null ||
        phoneController.text.isEmpty) {
      _setError('Semua field harus diisi');
      return false;
    }

    // Validasi email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _setError('Format email tidak valid');
      return false;
    }

    // Validasi password (minimal 6 karakter)
    if (passwordController.text.length < 6) {
      _setError('Password minimal 6 karakter');
      return false;
    }

    // Validasi nomor telepon (hanya angka)
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      _setError('Nomor telepon hanya boleh berisi angka');
      return false;
    }

    // Validasi umur (minimal 13 tahun)
    if (_selectedDate != null) {
      final DateTime now = DateTime.now();
      final DateTime minAge = DateTime(now.year - 13, now.month, now.day);
      if (_selectedDate!.isAfter(minAge)) {
        _setError('Umur minimal 13 tahun');
        return false;
      }
    }

    // Validasi nama (tidak boleh mengandung angka atau karakter khusus)
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text)) {
      _setError('Nama hanya boleh berisi huruf');
      return false;
    }

    return true;
  }

  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan';
        case 'weak-password':
          return 'Password terlalu lemah';
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
    nameController.clear();
    passwordController.clear();
    addressController.clear();
    birthDateController.clear();
    phoneController.clear();
    _selectedDate = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
