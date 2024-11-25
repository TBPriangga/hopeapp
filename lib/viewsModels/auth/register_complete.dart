import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../core/services/firestore_service.dart';

class CompleteProfileViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, dynamic> _userData;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  CompleteProfileViewModel(this._userData) {
    // Pre-fill data from Google Sign In
    emailController.text = _userData['email'] ?? '';
    nameController.text = _userData['name'] ?? '';
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;

  // Update birth date
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  // Complete profile method
  Future<bool> completeProfile() async {
    if (!_validateInputs()) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = UserModel(
        id: _userData['id'],
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate,
        phoneNumber: phoneController.text.trim(),
        photoUrl: _userData['photoUrl'],
      );

      // Save to Firestore
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
    if (addressController.text.isEmpty ||
        _selectedDate == null ||
        phoneController.text.isEmpty) {
      _errorMessage = 'Semua field harus diisi';
      notifyListeners();
      return false;
    }

    // Validasi nomor telepon (hanya angka)
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      _errorMessage = 'Nomor telepon hanya boleh berisi angka';
      notifyListeners();
      return false;
    }

    // Validasi tanggal lahir
    if (_selectedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_selectedDate!).inDays;

      // Minimal umur 13 tahun
      if (difference < (13 * 365)) {
        _errorMessage = 'Umur minimal 13 tahun';
        notifyListeners();
        return false;
      }
    }

    return true;
  }

  String _getErrorMessage(dynamic e) {
    if (e is Exception) {
      return 'Terjadi kesalahan: ${e.toString()}';
    }
    return 'Terjadi kesalahan yang tidak diketahui';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetForm() {
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
    addressController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
