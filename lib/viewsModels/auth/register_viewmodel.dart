import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
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

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;

  // Method untuk update tanggal
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  Future<bool> register() async {
    if (!_validateInputs()) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Register dengan Firebase Auth
      UserCredential userCredential = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Buat model user
      final user = UserModel(
        id: userCredential.user!.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate!,
        phoneNumber: phoneController.text.trim(),
      );

      // Simpan data user ke Firestore
      await _firestoreService.saveUserData(user);

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

  bool _validateInputs() {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        addressController.text.isEmpty ||
        _selectedDate == null ||
        phoneController.text.isEmpty) {
      _errorMessage = 'Semua field harus diisi';
      notifyListeners();
      return false;
    }

    // Validasi email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }

    // Validasi password (minimal 6 karakter)
    if (passwordController.text.length < 6) {
      _errorMessage = 'Password minimal 6 karakter';
      notifyListeners();
      return false;
    }

    // Validasi phone number (hanya angka)
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      _errorMessage = 'Nomor telepon hanya boleh berisi angka';
      notifyListeners();
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
    return 'Terjadi kesalahan: $e';
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
