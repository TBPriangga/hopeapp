import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/user_model.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';

class EditProfileViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  UserModel? _userData;
  File? _selectedImage;
  DateTime? _selectedDate;

  // Status baptis dan keanggotaan
  bool _isBaptized = false;
  bool _isChurchMember = true;
  String _originChurch = '';

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController originChurchController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;
  String? get errorMessage => _errorMessage;
  UserModel? get userData => _userData;
  File? get selectedImage => _selectedImage;
  bool get isBaptized => _isBaptized;
  bool get isChurchMember => _isChurchMember;
  String get originChurch => _originChurch;

  // Setters untuk status baptis dan keanggotaan
  void setBaptismStatus(bool value) {
    _isBaptized = value;
    notifyListeners();
  }

  void setMembershipStatus(bool value) {
    _isChurchMember = value;
    if (value) {
      _originChurch = ''; // Reset gereja asal jika menjadi anggota
      originChurchController.clear();
    }
    notifyListeners();
  }

  void setOriginChurch(String value) {
    _originChurch = value;
    notifyListeners();
  }

  // Hapus akun
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);

      final AuthService authService = AuthService();
      await authService.deleteAccount(password: password);

      _setLoading(false);
      return true;
    } catch (e) {
      String errorMsg = 'Gagal menghapus akun';

      // Cek apakah error adalah exception dengan pesan kustom
      if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      _setError(errorMsg);
      _setLoading(false);
      return false;
    }
  }

  // Memilih foto dari galeri
  Future<void> pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        await _cropImage(pickedImage.path);
      }
    } catch (e) {
      _setError('Gagal memilih foto: $e');
    }
  }

  // Mengambil foto dari kamera
  Future<void> takePhoto() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        await _cropImage(pickedImage.path);
      }
    } catch (e) {
      _setError('Gagal mengambil foto: $e');
    }
  }

  // Fungsi untuk crop foto
  Future<void> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto',
            toolbarColor: const Color(0xFF3949AB),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            statusBarColor: const Color(0xFF3949AB),
            activeControlsWidgetColor: const Color(0xFF3949AB),
          ),
        ],
      );

      if (croppedFile != null) {
        _selectedImage = File(croppedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Gagal melakukan crop foto: $e');
    }
  }

  // Upload foto ke Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _userData?.photoUrl;

    try {
      _isUploadingImage = true;
      notifyListeners();

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.${_selectedImage!.path.split('.').last}';
      final Reference ref = _storage
          .ref()
          .child('profile_images')
          .child(_userData!.id)
          .child(fileName);

      final UploadTask uploadTask = ref.putFile(_selectedImage!);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _isUploadingImage = false;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      _isUploadingImage = false;
      _setError('Gagal mengupload foto: $e');
      notifyListeners();
      return null;
    }
  }

  // Memuat data pengguna
  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          _userData = userData;
          _initializeControllers();

          // Inisialisasi status baptisan dan keanggotaan
          _isBaptized = userData.isBaptized;
          _isChurchMember = userData.isChurchMember;
          _originChurch = userData.originChurch;
          originChurchController.text = userData.originChurch;
        }
      }
    } catch (e) {
      _setError('Gagal memuat data pengguna: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _initializeControllers() {
    if (_userData != null) {
      nameController.text = _userData!.name;
      emailController.text = _userData!.email;
      phoneController.text = _userData!.phoneNumber ?? '';
      addressController.text = _userData!.address ?? '';
      if (_userData!.birthDate != null) {
        _selectedDate = _userData!.birthDate;
        birthDateController.text = _userData!.formattedBirthDate;
      }
    }
  }

  // Memperbarui tanggal lahir
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = date.toString().split(' ')[0];
    notifyListeners();
  }

  // Menyimpan profil
  Future<bool> saveProfile() async {
    try {
      _setLoading(true);

      final String? photoUrl = await _uploadImage();

      if (_userData == null) throw Exception('Data pengguna tidak ditemukan');

      final updatedUser = UserModel(
        id: _userData!.id,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate,
        phoneNumber: phoneController.text.trim(),
        photoUrl: photoUrl,
        role: _userData!.role,
        updatedAt: DateTime.now(),
        isBaptized: _isBaptized,
        isChurchMember: _isChurchMember,
        originChurch: _isChurchMember ? '' : _originChurch,
      );

      await _firestoreService.saveUserData(updatedUser);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    originChurchController.dispose();
    super.dispose();
  }
}
