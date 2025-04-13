import 'dart:io';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
  bool _isVerificationTimedOut = false;

  // Timeout dan countdown
  Timer? _verificationTimer;
  Timer? _countdownTimer;
  final int _verificationTimeoutMinutes = 10;
  DateTime? _verificationStartTime;
  int _remainingSeconds = 0;
  String _pendingRegistrationId = '';

  // Temporary user credentials
  UserCredential? _tempUserCredential;

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

  // Variabel untuk menyimpan verifikasi id
  String? _verificationId;
  String? _email;
  String? _password;

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
  User? get currentUser => _tempUserCredential?.user;
  bool get isVerificationTimedOut => _isVerificationTimedOut;

  // Countdown getter
  int get remainingSeconds => _remainingSeconds;
  String get countdownText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

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
        final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
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

  // Metode baru: Hanya memeriksa ketersediaan email tanpa mendaftarkan user
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isEmpty; // Email tersedia jika tidak ada metode sign-in
    } catch (e) {
      print('Error checking email availability: $e');
      // Dalam kasus error, asumsikan email tidak tersedia untuk berjaga-jaga
      return false;
    }
  }

  // Mulai timer untuk pemeriksaan verifikasi berkala
  void _startVerificationTimer() async {
    // Batalkan timer yang ada jika masih berjalan
    _verificationTimer?.cancel();
    _countdownTimer?.cancel();
    _isVerificationTimedOut = false;

    // Set waktu mulai dan total waktu countdown
    _verificationStartTime = DateTime.now();
    _remainingSeconds = _verificationTimeoutMinutes * 60;

    // Simpan informasi pendaftaran yang sedang berlangsung di SharedPreferences
    if (_tempUserCredential?.user != null) {
      await _savePendingRegistration(_tempUserCredential!.user!.uid);
    }

    // Mulai countdown timer yang diperbarui setiap detik
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _handleVerificationTimeout();
      }
    });

    // Buat timer yang memeriksa status verifikasi setiap 3 detik
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Cek apakah sudah melewati batas waktu
      final currentTime = DateTime.now();
      final elapsed = currentTime.difference(_verificationStartTime!).inMinutes;

      if (elapsed >= _verificationTimeoutMinutes) {
        timer.cancel();
        _countdownTimer?.cancel();
        _handleVerificationTimeout();
        return;
      }

      // Cek status verifikasi jika user sedang login
      if (_tempUserCredential?.user != null) {
        final verified = await checkEmailVerificationStatus();
        if (verified) {
          timer.cancel();
          _countdownTimer?.cancel();
          await _clearPendingRegistration(); // Hapus data pendaftaran tertunda karena sukses
        }
      } else {
        // Jika tidak ada user terdeteksi, batalkan timer
        timer.cancel();
        _countdownTimer?.cancel();
      }
    });
  }

  // Handle verification timeout
  Future<void> _handleVerificationTimeout() async {
    print('Verification timed out');
    _isVerificationTimedOut = true;

    // Hapus user sementara dengan logging detail untuk debugging
    try {
      print('Attempting to delete temporary user due to timeout');

      if (_tempUserCredential?.user != null) {
        print(
            'User exists: ${_tempUserCredential!.user!.uid}, email: ${_tempUserCredential!.user!.email}');

        try {
          // Pastikan user credential masih fresh
          await _tempUserCredential!.user!.reload();
          print('User reloaded successfully');

          // Verifikasi apakah email sudah diverifikasi
          final isVerified = _tempUserCredential!.user!.emailVerified;
          print('Email verified status: $isVerified');

          if (!isVerified) {
            try {
              // Coba hapus akun
              await _tempUserCredential!.user!.delete();
              print('Successfully deleted unverified user');
            } catch (deleteError) {
              print('Error deleting user: $deleteError');

              // Jika error karena requires-recent-login, coba login ulang
              if (deleteError is FirebaseAuthException &&
                  deleteError.code == 'requires-recent-login' &&
                  _email != null &&
                  _password != null) {
                try {
                  print('Attempting to re-authenticate');
                  // Re-authenticate
                  final credential = EmailAuthProvider.credential(
                    email: _email!,
                    password: _password!,
                  );
                  await _tempUserCredential!.user!
                      .reauthenticateWithCredential(credential);

                  // Coba delete lagi
                  await _tempUserCredential!.user!.delete();
                  print('Successfully deleted user after re-authentication');
                } catch (reauthError) {
                  print('Re-authentication failed: $reauthError');
                }
              }
            }
          }
        } catch (reloadError) {
          print('Error reloading user: $reloadError');
        }
      } else {
        print('No user to delete (null credential)');
      }

      // Bersihkan credential dan data registrasi tertunda
      _tempUserCredential = null;
      await _clearPendingRegistration();

      _setError('Waktu verifikasi email telah habis. Silakan coba lagi.');
    } catch (e) {
      print('Error handling verification timeout: $e');
      _setError('Waktu verifikasi email telah habis. Error: $e');
    }

    // Reset states
    _verificationEmailSent = false;
    notifyListeners();
  }

  // Simpan informasi pendaftaran yang tertunda
  Future<void> _savePendingRegistration(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pendingRegistrationId = userId;
      await prefs.setString('pending_registration_id', userId);
      await prefs.setInt(
          'pending_registration_expires',
          DateTime.now()
              .add(Duration(minutes: _verificationTimeoutMinutes))
              .millisecondsSinceEpoch);
      await prefs.setString('pending_registration_email', _email ?? '');
      await prefs.setString('pending_registration_password', _password ?? '');

      print('Saved pending registration info: $userId');
    } catch (e) {
      print('Failed to save pending registration: $e');
    }
  }

  // Hapus informasi pendaftaran tertunda
  Future<void> _clearPendingRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_registration_id');
      await prefs.remove('pending_registration_expires');
      await prefs.remove('pending_registration_email');
      await prefs.remove('pending_registration_password');
      _pendingRegistrationId = '';
      print('Cleared pending registration info');
    } catch (e) {
      print('Failed to clear pending registration: $e');
    }
  }

  // Cek apakah ada pendaftaran tertunda yang perlu dibersihkan
  // Dipanggil saat aplikasi dimulai
  Future<void> checkPendingRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingId = prefs.getString('pending_registration_id');
      final expiresAt = prefs.getInt('pending_registration_expires');
      final pendingEmail = prefs.getString('pending_registration_email');
      final pendingPassword = prefs.getString('pending_registration_password');

      if (pendingId != null && expiresAt != null) {
        _pendingRegistrationId = pendingId;
        print('Found pending registration: $pendingId');

        // Cek apakah sudah kadaluarsa
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now >= expiresAt) {
          print('Pending registration expired, cleaning up...');

          // Coba hapus user yang tidak terverifikasi
          if (pendingEmail != null && pendingPassword != null) {
            try {
              print('Attempting to delete expired registration: $pendingEmail');

              // Coba login dengan kredensial yang tersimpan
              try {
                final credential =
                    await _firebaseAuth.signInWithEmailAndPassword(
                        email: pendingEmail, password: pendingPassword);

                if (credential.user != null) {
                  // Reload untuk mendapatkan status terbaru
                  await credential.user!.reload();

                  // Cek apakah email sudah diverifikasi
                  if (!credential.user!.emailVerified) {
                    // Hapus jika belum diverifikasi
                    await credential.user!.delete();
                    print(
                        'Successfully deleted unverified user: $pendingEmail');
                  } else {
                    print('User already verified, not deleting: $pendingEmail');
                  }

                  // Logout
                  await _firebaseAuth.signOut();
                }
              } catch (loginError) {
                print('Error signing in to delete user: $loginError');

                // Coba cek apakah email masih tersedia
                final methods = await _firebaseAuth
                    .fetchSignInMethodsForEmail(pendingEmail);
                if (methods.isNotEmpty) {
                  // Email masih terdaftar, tapi kita tidak bisa menghapusnya
                  print(
                      'Email still registered but cannot delete: $pendingEmail');
                }
              }
            } catch (e) {
              print('Error during cleanup: $e');
            }
          }

          await _clearPendingRegistration();
        } else {
          // Masih valid, tetapi kita tidak perlu melakukan apa-apa
          // Biarkan user menyelesaikan proses dengan normal
          final remainingMillis = expiresAt - now;
          print(
              'Pending registration still valid for ${remainingMillis / 1000} seconds');
        }
      }
    } catch (e) {
      print('Error checking pending registration: $e');
    }
  }

  // Membersihkan user sementara
  Future<bool> _deleteTempUser() async {
    try {
      // Jika ada user yang login, coba hapus
      if (_tempUserCredential?.user != null) {
        print(
            'Attempting to delete user: ${_tempUserCredential?.user?.uid}, email: ${_tempUserCredential?.user?.email}');

        try {
          // Make sure the user is fresh
          await _tempUserCredential!.user!.reload();
          print('User reloaded successfully');

          // Only delete if not verified
          final isVerified = _tempUserCredential!.user!.emailVerified;
          print('Email verified status: $isVerified');

          if (!isVerified) {
            try {
              await _tempUserCredential!.user!.delete();
              print('Temporary user deleted successfully');
              _tempUserCredential = null;
              return true;
            } catch (deleteError) {
              print('Error deleting user: $deleteError');

              // Coba handle kasus requires-recent-login
              if (deleteError is FirebaseAuthException &&
                  deleteError.code == 'requires-recent-login' &&
                  _email != null &&
                  _password != null) {
                try {
                  print('Attempting to re-authenticate');

                  // Re-authenticate user
                  final credential = EmailAuthProvider.credential(
                    email: _email!,
                    password: _password!,
                  );

                  await _tempUserCredential!.user!
                      .reauthenticateWithCredential(credential);
                  print('Re-authentication successful');

                  // Coba lagi hapus
                  await _tempUserCredential!.user!.delete();
                  print('User deleted after re-authentication');
                  _tempUserCredential = null;
                  return true;
                } catch (reauthError) {
                  print('Re-authentication failed: $reauthError');
                  throw reauthError; // Re-throw untuk ditangani di luar
                }
              } else {
                throw deleteError; // Re-throw untuk ditangani di luar
              }
            }
          } else {
            print('User already verified, not deleting');
            return false;
          }
        } catch (reloadError) {
          print('Error reloading user: $reloadError');

          // Coba sign out dulu
          try {
            await _firebaseAuth.signOut();
            print('Signed out user after reload error');
          } catch (signOutError) {
            print('Error signing out: $signOutError');
          }

          _tempUserCredential = null;
          return false;
        }
      } else {
        print('No user credential to delete');
      }

      // Bersihkan referensi
      _tempUserCredential = null;
      return true;
    } catch (e) {
      print('Error in _deleteTempUser: $e');

      // Check if error is because user is already signed out
      if (e is FirebaseAuthException &&
          (e.code == 'user-not-found' || e.code == 'no-current-user')) {
        _tempUserCredential = null;
        return true;
      }

      // Try to sign out anyway
      try {
        await _firebaseAuth.signOut();
        print('Signed out after error');
      } catch (signOutError) {
        print('Error signing out: $signOutError');
      }

      _tempUserCredential = null;
      return false;
    }
  }

  // Verifikasi email dengan metode normal yang DIMODIFIKASI
  // Kita membuat akun Firebase Auth sementara untuk verifikasi
  Future<bool> sendVerificationEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _setError('Email dan password harus diisi');
      return false;
    }

    try {
      _setLoading(true);

      // Simpan email dan password untuk digunakan nanti setelah verifikasi
      _email = emailController.text.trim();
      _password = passwordController.text.trim();

      if (kDebugMode) {
        // DEVELOPMENT MODE: Simulasikan sukses verifikasi
        print('DEBUG: Simulasi verifikasi email');
        await Future.delayed(
            const Duration(seconds: 1)); // Simulasi delay network

        _verificationEmailSent = true;
        _isEmailVerified = true; // Langsung set verified=true untuk debug

        _setLoading(false);
        notifyListeners();
        return true;
      }

      // Kode normal untuk mode produksi
      _registrationAttempts++;

      // Periksa dulu apakah email tersedia (tidak terdaftar)
      bool isEmailAvailable = await checkEmailAvailability(_email!);

      if (!isEmailAvailable) {
        _setError('Email sudah terdaftar. Silakan gunakan email lain.');
        _setLoading(false);
        return false;
      }

      // Jika sudah mencoba beberapa kali, tambahkan jeda
      if (_registrationAttempts > 1) {
        await Future.delayed(Duration(seconds: _registrationAttempts));
      }

      // Hapus user sementara yang mungkin masih ada
      await _deleteTempUser();
      await _clearPendingRegistration();

      // Buat akun sementara untuk dikirim email verifikasi
      try {
        _tempUserCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        print(
            'Created temporary user: ${_tempUserCredential?.user?.uid}, ${_tempUserCredential?.user?.email}');

        // Kirim email verifikasi
        await _tempUserCredential!.user?.sendEmailVerification();
        print('Verification email sent');

        // Set flag
        _verificationEmailSent = true;

        // Mulai timer pemeriksaan
        _startVerificationTimer();

        _registrationAttempts = 0; // Reset counter setelah berhasil
        _setLoading(false);
        notifyListeners();
        return true;
      } catch (e) {
        // Tangani error
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            _setError('Email sudah terdaftar. Silakan gunakan email lain.');
          } else {
            _setError('Error saat mendaftarkan akun: ${e.message}');
          }
        } else {
          _setError('Terjadi kesalahan: $e');
        }
        _setLoading(false);
        return false;
      }
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

  // METODE YANG DIPERBAIKI: Verifikasi email dengan penanganan khusus untuk debugging
  Future<bool> checkEmailVerificationStatus() async {
    if (kDebugMode) {
      // DEVELOPMENT MODE: Selalu return true untuk bypass verifikasi email
      print('DEBUG: Bypassing email verification check');
      _isEmailVerified = true;
      notifyListeners();
      return true;
    }

    try {
      // Cek apakah ada user sementara
      if (_tempUserCredential == null || _tempUserCredential!.user == null) {
        print('No temporary user found for verification check');
        return false;
      }

      // Sign out dulu jika ada user lain yang sedang login
      bool wasLoggedIn = false;
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null &&
          currentUser.uid != _tempUserCredential!.user!.uid) {
        print('Another user was logged in, signing out first');
        await _firebaseAuth.signOut();
        wasLoggedIn = true;
      }

      // Cara 1: Coba login ulang untuk mendapatkan status terbaru
      try {
        if (_email != null && _password != null) {
          print('Attempting to sign in to check verification status: $_email');

          // Sign in untuk mendapatkan user credential yang fresh
          final freshCredential = await _firebaseAuth
              .signInWithEmailAndPassword(email: _email!, password: _password!);

          // Update temp credential
          _tempUserCredential = freshCredential;

          // Cek status verifikasi dari credential baru
          final isVerified = freshCredential.user!.emailVerified;
          print('Fresh sign in verification status: $isVerified');

          if (isVerified) {
            _isEmailVerified = true;
            notifyListeners();
            return true;
          }
        }
      } catch (loginError) {
        print('Error re-signing in to check status: $loginError');
        // Lanjutkan ke cara alternatif jika login gagal
      }

      // Cara 2: Coba dengan reload
      try {
        print('Attempting to reload user: ${_tempUserCredential!.user!.email}');

        // Force reload user
        await _tempUserCredential!.user!.reload();

        // Get fresh instance of user
        final freshUser = _firebaseAuth.currentUser;
        if (freshUser != null) {
          print('User reloaded, checking verification status');

          // Cek status setelah reload
          final isVerified = freshUser.emailVerified;
          print('Reload verification status: $isVerified');

          if (isVerified) {
            _isEmailVerified = true;
            notifyListeners();
            return true;
          }
        } else {
          print('No user after reload');
        }
      } catch (reloadError) {
        print('Error reloading user: $reloadError');
        // Lanjutkan ke cara alternatif jika reload gagal
      }

      // Cara 3: Cek dengan fetchSignInMethodsForEmail
      try {
        if (_email != null) {
          print('Checking sign-in methods for: $_email');
          final methods =
              await _firebaseAuth.fetchSignInMethodsForEmail(_email!);

          // Jika email sudah diverifikasi, email+password akan muncul di methods
          print('Available sign-in methods: $methods');

          // Ini hanya indikasi saja, tidak 100% akurat
          if (methods.contains('password') && methods.isNotEmpty) {
            print('Email found in sign-in methods, might be verified');
            // Kita tidak set verified = true disini, karena ini hanya indikasi
          }
        }
      } catch (e) {
        print('Error checking sign-in methods: $e');
      }

      // Hasil akhir: jika semua cara gagal mendeteksi verifikasi
      return _isEmailVerified;
    } catch (e) {
      print('Error checking verification status: $e');
      return false; // Tetap kembalikan false pada production
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

      // Cek apakah user sementara masih ada
      if (_tempUserCredential == null || _tempUserCredential!.user == null) {
        _setError(
            'Sesi verifikasi telah berakhir. Silakan coba lagi dari awal.');
        _setLoading(false);
        return;
      }

      // Reload user terlebih dahulu
      await _tempUserCredential!.user!.reload();

      // Cek apakah sudah terverifikasi
      final isVerified = _tempUserCredential!.user!.emailVerified;
      if (isVerified) {
        _isEmailVerified = true;
        _setLoading(false);
        notifyListeners();
        return;
      }

      // Kirim ulang email verifikasi
      await _tempUserCredential!.user!.sendEmailVerification();
      print('Verification email resent');

      // Reset timer untuk memberikan waktu penuh lagi
      _startVerificationTimer();

      _setLoading(false);
      _verificationEmailSent = true;
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError('Gagal mengirim ulang email verifikasi: $e');
    }
  }

  // Proses registrasi SETELAH email telah diverifikasi dan data lengkap
  Future<bool> completeRegistration() async {
    // Jika dalam debug mode, bypass validasi email
    if (kDebugMode) {
      _isEmailVerified = true;
    }

    if (!_validateInputs()) return false;

    try {
      _setLoading(true);

      // Validasi apakah email sudah terverifikasi
      if (!_isEmailVerified && !kDebugMode) {
        _setError('Email belum diverifikasi');
        _setLoading(false);
        return false;
      }

      // POINT KRITIS: Gunakan kredensial yang sudah ada dan terverifikasi
      // Akun sudah dibuat saat verifikasi, tidak perlu buat akun baru
      String userId;

      if (kDebugMode) {
        // Dalam mode debug, buat akun user baru jika belum ada
        if (_tempUserCredential == null) {
          _tempUserCredential =
              await _firebaseAuth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
        }
        userId = _tempUserCredential?.user?.uid ??
            'temp-${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Dalam mode produksi, harus ada user yang telah terverifikasi
        if (_tempUserCredential == null || _tempUserCredential!.user == null) {
          _setError(
              'Sesi verifikasi telah berakhir. Silakan verifikasi email terlebih dahulu.');
          _setLoading(false);
          return false;
        }
        userId = _tempUserCredential!.user!.uid;
      }

      // Get FCM Token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print("Error mendapatkan FCM token: $e");
      }

      // Upload foto jika ada
      final String? photoUrl = await _uploadImage(userId);

      // Buat user model dengan role user
      final userModel = UserModel(
        id: userId,
        email: _tempUserCredential?.user?.email ?? emailController.text.trim(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        birthDate: _selectedDate ??
            DateTime.now().subtract(
                const Duration(days: 365 * 20)), // Default 20 tahun jika null
        phoneNumber: phoneController.text.trim(),
        photoUrl: photoUrl, // Use uploaded URL if available
        fcmToken: fcmToken,
        role: 'user',
        createdAt: DateTime.now(),
        isBaptized: _isBaptized,
        isChurchMember: _isChurchMember,
        originChurch: !_isChurchMember ? originChurchController.text : '',
      );

      // Simpan data user ke Firestore
      try {
        await _firestoreService.saveUserData(userModel);

        // Subscribe ke topik notifikasi jika perlu
        await _authService.subscribeToNotificationTopics();

        // Hapus informasi pendaftaran yang tertunda karena sudah selesai
        await _clearPendingRegistration();
      } catch (e) {
        print("Error menyimpan data user: $e");
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
    } finally {
      // Jangan hapus user sementara karena ini adalah user yang sebenarnya
      // Bersihkan timer
      _verificationTimer?.cancel();
      _countdownTimer?.cancel();
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

  // Batalkan registrasi dan batalkan semua proses verifikasi
  Future<bool> cancelRegistration() async {
    try {
      _setLoading(true);

      // Stop all timers
      _verificationTimer?.cancel();
      _countdownTimer?.cancel();

      // Delete the temporary user from Firebase
      final success = await _deleteTempUser();
      print('User deletion result: $success');

      // Bersihkan informasi pendaftaran tertunda
      await _clearPendingRegistration();

      // Reset all verification states
      _verificationEmailSent = false;
      _isEmailVerified = false;
      _isVerificationTimedOut = false;
      _remainingSeconds = 0;

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      print('Error cancelling registration: $e');
      _setLoading(false);
      _setError('Gagal membatalkan registrasi: $e');
      return false;
    }
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
    _email = null;
    _password = null;
    _tempUserCredential = null;
    _verificationTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingSeconds = 0;
    _isVerificationTimedOut = false;

    // Bersihkan juga data pendaftaran tertunda
    _clearPendingRegistration();

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
    _verificationTimer?.cancel();
    _countdownTimer?.cancel();

    // Coba hapus user sementara jika dispose terpanggil dan belum selesai registrasi
    if (_tempUserCredential != null && !_isEmailVerified) {
      _deleteTempUser();
    }

    super.dispose();
  }
}
