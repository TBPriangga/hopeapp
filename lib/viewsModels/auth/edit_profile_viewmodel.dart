import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _userData;
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isUploadingImage = false;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get userData => _userData;
  File? get selectedImage => _selectedImage;
  bool get isUploadingImage => _isUploadingImage;

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<void> takePhoto() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to take photo: $e');
    }
  }

// Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _userData?.photoUrl;

    try {
      _isUploadingImage = true;
      notifyListeners();

      final user = _authService.currentUser;
      if (user == null) throw Exception('User not found');

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImage!.path)}';
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child(user.uid)
          .child(fileName);

      final UploadTask uploadTask = storageRef.putFile(_selectedImage!);

      // Wait for upload to complete
      await uploadTask.whenComplete(() {});

      // Get download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      _isUploadingImage = false;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      _isUploadingImage = false;
      _setError('Failed to upload image: $e');
      notifyListeners();
      return null;
    }
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          _userData = userData;
          // Pre-fill form data
          nameController.text = userData.name;
          emailController.text = userData.email;
          phoneController.text = userData.phoneNumber ?? '';
          addressController.text = userData.address ?? '';
          if (userData.birthDate != null) {
            _selectedDate = userData.birthDate;
            birthDateController.text =
                DateFormat('dd/MM/yyyy').format(userData.birthDate!);
          }
        }
      }
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update birth date
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  // Save profile changes
  Future<bool> saveProfile() async {
    if (!_validateInputs()) return false;

    try {
      _setLoading(true);

      // Upload image first if selected
      String? photoUrl = await _uploadImage();

      final user = _authService.currentUser;
      if (user == null) throw Exception('User not found');

      // Create updated user model
      final updatedUser = UserModel(
        id: user.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate,
        phoneNumber: phoneController.text.trim(),
        photoUrl:
            photoUrl ?? _userData?.photoUrl, // Use new URL or keep existing
      );

      // Save to Firestore
      await _firestoreService.saveUserData(updatedUser);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      _setError('Name and email are required');
      return false;
    }

    // Email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _setError('Invalid email format');
      return false;
    }

    // Phone validation (if provided)
    if (phoneController.text.isNotEmpty &&
        !RegExp(r'^[0-9-]+$').hasMatch(phoneController.text)) {
      _setError('Invalid phone number format');
      return false;
    }

    return true;
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
