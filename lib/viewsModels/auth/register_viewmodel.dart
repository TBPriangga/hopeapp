import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;

  // Email verification
  bool _isEmailValid = false;
  String? _emailValidationMessage;
  bool _isVerifyingEmail = false;
  bool _verificationEmailSent = false;
  bool _isEmailVerified = false;
  int _registrationAttempts = 0;

  // Foto profile
  File? _selectedImage;
  bool _isUploadingImage = false;

  // Church membership
  bool _isBaptized = false; // Default: belum dibaptis
  bool _isChurchMember = true; // Default: anggota jemaat

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController originChurchController = TextEditingController();

  // Default avatar
  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  bool get isEmailValid => _isEmailValid;
  String? get emailValidationMessage => _emailValidationMessage;
  bool get isVerifyingEmail => _isVerifyingEmail;
  bool get verificationEmailSent => _verificationEmailSent;
  bool get isEmailVerified => _isEmailVerified;
  File? get selectedImage => _selectedImage;
  bool get isUploadingImage => _isUploadingImage;
  bool get isBaptized => _isBaptized;
  bool get isChurchMember => _isChurchMember;
  bool get showVerifyButton => _isEmailValid && !_isEmailVerified;
  int get registrationAttempts => _registrationAttempts;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Baptism status
  void setBaptismStatus(bool value) {
    _isBaptized = value;
    notifyListeners();
  }

  // Membership status
  void setMembershipStatus(bool value) {
    _isChurchMember = value;
    notifyListeners();
  }

  // Set origin church
  void setOriginChurch(String value) {
    notifyListeners();
  }

  // Update tanggal
  void updateBirthDate(DateTime date) {
    _selectedDate = date;
    birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
    notifyListeners();
  }

  // Email validation
  Future<void> checkEmailFormat(String email) async {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    _isVerifyingEmail = true;
    notifyListeners();

    if (kDebugMode) {
      // Dalam debug mode, selalu anggap email valid
      _isEmailValid = true;
      _emailValidationMessage = "Format email valid (debug mode)";
      _isVerifyingEmail = false;
      notifyListeners();
      return;
    }

    if (emailRegex.hasMatch(email)) {
      _isEmailValid = true;
      _emailValidationMessage = "Format email valid";

      // Verifikasi tambahan untuk mengecek apakah email sudah terdaftar
      try {
        final methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          _isEmailValid = false;
          _emailValidationMessage =
              "Email sudah terdaftar. Silakan gunakan email lain.";
        }
      } catch (e) {
        print('Error checking email availability: $e');
        // Tetap tandai valid jika error hanya pada pengecekan ketersediaan
      }
    } else {
      _isEmailValid = false;
      _emailValidationMessage = "Format email tidak valid";
    }

    _isVerifyingEmail = false;
    notifyListeners();
  }

  void resetEmailValidation() {
    _isEmailValid = false;
    _emailValidationMessage = null;
    notifyListeners();
  }

  // Foto profil methods
  Future<void> pickImage() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? pickedImage = await imagePicker.pickImage(
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

  Future<void> takePhoto() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? pickedImage = await imagePicker.pickImage(
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

  void removePhoto() {
    _selectedImage = null;
    notifyListeners();
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      _isUploadingImage = true;
      notifyListeners();

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(userId)
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

  // Verifikasi email dengan metode normal YANG TELAH DIMODIFIKASI
  Future<bool> sendVerificationEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _setError('Email dan password harus diisi');
      return false;
    }

    try {
      _setLoading(true);

      if (kDebugMode) {
        // DEVELOPMENT MODE: Skip Firebase Auth dan simulasikan sukses
        print('DEBUG: Melewati registrasi Firebase dan verifikasi email');
        await Future.delayed(Duration(seconds: 1)); // Simulasi delay network

        // Mencoba membuat credential di Firebase tapi tidak menunggu verifikasi
        try {
          await _authService.register(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
        } catch (e) {
          print('Error registrasi Firebase, tapi diabaikan untuk debug: $e');
        }

        // Anggap email sudah terverifikasi untuk debug
        _verificationEmailSent = true;
        _isEmailVerified = true; // Langsung set verified=true untuk debug

        _setLoading(false);
        notifyListeners();
        return true;
      }

      // Kode normal untuk mode produksi
      _registrationAttempts++;

      // Jika sudah mencoba beberapa kali, tambahkan jeda
      if (_registrationAttempts > 1) {
        // Tambahkan jeda untuk menghindari rate limit
        await Future.delayed(Duration(seconds: _registrationAttempts));
      }

      // Register with Firebase Auth (without saving to Firestore yet)
      UserCredential userCredential = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Send verification email
      try {
        await userCredential.user!.sendEmailVerification();
      } catch (e) {
        print('Error sending verification email: $e');
        // Lanjutkan meski gagal kirim email
      }

      _verificationEmailSent = true;
      _registrationAttempts = 0; // Reset counter setelah berhasil
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);

      // Dalam debug mode, lupakan error
      if (kDebugMode) {
        print('DEBUG: Error diabaikan: $e');
        _verificationEmailSent = true;
        _isEmailVerified = true;
        notifyListeners();
        return true;
      }

      // Tangani kasus khusus untuk blocked request
      if (e.toString().contains('blocked') ||
          e.toString().contains('unusual activity') ||
          e.toString().contains('too-many-requests')) {
        // Jika dalam debug mode, berikan pesan khusus
        if (kDebugMode) {
          _setError(
              'Firebase memblokir request. Gunakan jaringan berbeda atau restart aplikasi. Mode Debug tersedia untuk mencoba dengan metode alternatif.');

          // Aktifkan mode alternatif untuk percobaan berikutnya
          _registrationAttempts +=
              2; // Pastikan menggunakan mode bypass pada percobaan berikutnya
        } else {
          _setError(
              'Permintaan diblokir karena aktivitas tidak biasa. Silakan coba beberapa saat lagi atau gunakan jaringan berbeda.');
        }
      } else {
        _setError(_getErrorMessage(e));
      }

      return false;
    }
  }

  // Verifikasi email dengan penanganan khusus untuk debugging
  Future<bool> checkEmailVerificationStatus() async {
    if (kDebugMode) {
      // DEVELOPMENT MODE: Selalu return true untuk bypass verifikasi email
      print('DEBUG: Bypassing email verification check');
      _isEmailVerified = true;
      notifyListeners();
      return true;
    }

    try {
      // Re-authenticate to get fresh user
      try {
        await FirebaseAuth.instance.currentUser?.reload();
      } catch (e) {
        print('Error reloading user: $e');
        // Coba login ulang jika reload gagal
        if (e is FirebaseAuthException && e.code == 'user-token-expired') {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
          } catch (signInError) {
            print('Error signing in again: $signInError');
          }
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _isEmailVerified = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking verification status: $e');
      return kDebugMode; // Return true in debug mode, false otherwise
    }
  }

  Future<void> resendVerificationEmail() async {
    if (kDebugMode) {
      print('DEBUG: Skipping resend verification email');
      _verificationEmailSent = true;
      _isEmailVerified = true;
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);

      // Cek apakah user masih valid
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Jika user null, coba login ulang
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        user = userCredential.user;
      }

      // Kirim ulang email verifikasi
      if (user != null) {
        await user.sendEmailVerification();
        _setLoading(false);
        _verificationEmailSent = true;
        notifyListeners();
      } else {
        throw Exception('Tidak dapat mengidentifikasi pengguna');
      }
    } catch (e) {
      _setLoading(false);
      _setError('Gagal mengirim ulang email verifikasi: $e');
    }
  }

  // Proses registrasi setelah verifikasi email
  Future<bool> completeRegistration() async {
    // Jika dalam debug mode, bypass validasi email
    if (kDebugMode) {
      _isEmailVerified = true;
    }

    if (!_validateInputs()) return false;

    try {
      _setLoading(true);

      // Get the current user after verification
      final User? user = FirebaseAuth.instance.currentUser;
      final String userId =
          user?.uid ?? 'debug-user-id-${DateTime.now().millisecondsSinceEpoch}';

      // Jika tidak ada user (mungkin karena error atau debug mode), gunakan anonim
      if (user == null && kDebugMode) {
        print("DEBUG: Tidak ada user aktif, mencoba membuat user baru");

        try {
          // Coba membuat user jika tidak ada
          final UserCredential userCredential = await _authService.register(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
        } catch (e) {
          print("DEBUG: Error saat mencoba membuat user baru: $e");
        }
      }

      // Upload foto jika ada
      final String? photoUrl = await _uploadImage(userId);

      // Get FCM Token - dengan error handling untuk debug
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print("DEBUG: Error mendapatkan FCM token: $e");
      }

      // Buat user model dengan role user
      final userModel = UserModel(
        id: userId,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate ??
            DateTime.now().subtract(
                Duration(days: 365 * 20)), // Default 20 tahun jika null
        phoneNumber: phoneController.text.trim(),
        photoUrl: photoUrl, // Use uploaded URL if available
        fcmToken: fcmToken,
        role: 'user',
        createdAt: DateTime.now(),
      );

      // Simpan data user ke Firestore
      try {
        await _firestoreService.saveUserData(userModel);
      } catch (e) {
        print("DEBUG: Error menyimpan data user: $e");
        if (!kDebugMode) {
          throw e; // Re-throw jika bukan debug mode
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);

      if (kDebugMode) {
        print("DEBUG: Error diabaikan dalam completeRegistration: $e");
        return true; // Anggap sukses dalam debug mode
      }

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
    // Jika dalam mode debug, bypass validasi email verification
    if (kDebugMode) {
      // Skip email verification check in debug mode
      print('Debug mode: Skipping email verification validation');
      _isEmailVerified = true;
    } else if (!_isEmailVerified) {
      _setError('Email belum diverifikasi');
      return false;
    }

    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        _selectedDate == null ||
        phoneController.text.isEmpty) {
      _setError('Semua field harus diisi');
      return false;
    }

    // Validasi nomor telepon (hanya angka)
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      _setError('Nomor telepon hanya boleh berisi angka');
      return false;
    }

    // Validasi umur (minimal 13 tahun) - DILEWATI DALAM DEBUG MODE
    if (_selectedDate != null && !kDebugMode) {
      final DateTime now = DateTime.now();
      final DateTime minAge = DateTime(now.year - 13, now.month, now.day);
      if (_selectedDate!.isAfter(minAge)) {
        _setError('Umur minimal 13 tahun');
        return false;
      }
    }

    // Validasi nama (tidak boleh mengandung angka atau karakter khusus) - DILEWATI DALAM DEBUG MODE
    if (!kDebugMode &&
        !RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameController.text)) {
      _setError('Nama hanya boleh berisi huruf');
      return false;
    }

    // Validasi asal gereja jika partisipan - DILEWATI DALAM DEBUG MODE
    if (!kDebugMode &&
        !_isChurchMember &&
        originChurchController.text.isEmpty) {
      _setError('Asal gereja harus diisi');
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
        case 'too-many-requests':
          return 'Terlalu banyak permintaan. Silakan coba beberapa saat lagi.';
        case 'network-request-failed':
          return 'Masalah koneksi internet. Periksa koneksi Anda dan coba lagi.';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } else if (e.toString().contains('We have blocked all requests')) {
      return 'Permintaan diblokir karena aktivitas tidak biasa. Silakan coba beberapa saat lagi atau gunakan jaringan berbeda.';
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
    originChurchController.clear();
    _selectedDate = null;
    _errorMessage = null;
    _selectedImage = null;
    _isBaptized = false;
    _isChurchMember = true;
    _registrationAttempts = 0;
    _isEmailValid = false;
    _isEmailVerified = false;
    _emailValidationMessage = null;
    _verificationEmailSent = false;
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
    originChurchController.dispose();
    super.dispose();
  }
}
