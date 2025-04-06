import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Flag untuk mode debug
  bool get _isDebugMode => kDebugMode;

  // Metode verifikasi email yang sudah dimodifikasi untuk debug
  Future<bool> isEmailVerified() async {
    if (_isDebugMode) {
      // Selalu anggap email terverifikasi dalam mode debug
      print('DEBUG: Bypassing email verification check');
      return true;
    }

    try {
      User? user = _auth.currentUser;
      // Reload user untuk mendapatkan status terbaru
      await user?.reload();
      user = _auth.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return _isDebugMode ? true : false; // Selalu return true dalam debug mode
    }
  }

  // Kirim ulang email verifikasi
  Future<void> sendEmailVerification() async {
    if (_isDebugMode) {
      print('DEBUG: Skipping send verification email');
      return; // Skip in debug mode
    }

    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not found');
      if (user.email == null) throw Exception('User email not found');

      try {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // 1. Hapus file dari Firebase Storage
        try {
          final storage = FirebaseStorage.instance;
          final profileImageRef =
              storage.ref().child('profile_images').child(user.uid);

          // List semua file di folder profile_images/{userId}
          final ListResult result = await profileImageRef.listAll();

          // Hapus semua file yang ditemukan
          for (final Reference ref in result.items) {
            await ref.delete();
            print('Deleted profile image: ${ref.fullPath}');
          }

          // Hapus folder temp jika ada
          try {
            final tempRef = storage.ref().child('temp').child(user.uid);
            final tempFiles = await tempRef.listAll();

            for (final Reference ref in tempFiles.items) {
              await ref.delete();
              print('Deleted temp file: ${ref.fullPath}');
            }
          } catch (e) {
            print('Note: No temp files to delete or error: $e');
          }

          print('Successfully deleted user storage data');
        } catch (storageError) {
          // Hanya log error, tetapi tetap lanjutkan proses
          print('Warning: Failed to delete storage data: $storageError');
        }

        // 2. Hapus data user dari Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // 3. Unsubscribe dari topic notifikasi
        await unsubscribeFromNotificationTopics();

        // 4. Hapus akun Authentication
        await user.delete();

        print('User account successfully deleted');
      } catch (e) {
        print('Error during re-authentication: $e');

        // Pesan error yang lebih spesifik
        if (e is FirebaseAuthException) {
          if (e.code == 'wrong-password') {
            throw Exception('Kata sandi yang Anda masukkan salah');
          } else if (e.code == 'requires-recent-login') {
            throw Exception(
                'Sesi Anda telah habis. Silakan logout dan login kembali untuk menghapus akun');
          } else if (e.code == 'invalid-credential') {
            throw Exception(
                'Kredensial tidak valid. Pastikan kata sandi benar');
          }
        }

        throw e;
      }
    } catch (e) {
      print('Error deleting account: $e');
      throw e; // Lemparkan error untuk ditangani di ViewModel
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception('Failed to send reset password email: $e');
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Confirm password reset
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not found');

      // Get credentials for re-authentication
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Login dengan email dan password
  Future<UserCredential> login(String email, String password) async {
    try {
      // Login dengan Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifikasi bahwa user bukan admin
      if (await _isAdmin(credential.user!.uid)) {
        await _auth.signOut();
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      // Verifikasi bahwa email telah diverifikasi - DILEWATI DALAM DEBUG MODE
      if (!_isDebugMode && !credential.user!.emailVerified) {
        // Kirim ulang email verifikasi
        await credential.user!.sendEmailVerification();
        await _auth.signOut();
        throw Exception(
            'Email belum diverifikasi. Silakan cek email Anda untuk verifikasi.');
      }

      // Subscribe ke topics setelah login berhasil
      await subscribeToNotificationTopics();

      return credential;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Method untuk subscribe ke topics
  Future<void> subscribeToNotificationTopics() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('daily_word');
      await FirebaseMessaging.instance.subscribeToTopic('events');
      await FirebaseMessaging.instance.subscribeToTopic('birthdays');
      print('Successfully subscribed to all notification topics');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  // Method untuk unsubscribe dari topics
  Future<void> unsubscribeFromNotificationTopics() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('daily_word');
      await FirebaseMessaging.instance.unsubscribeFromTopic('events');
      await FirebaseMessaging.instance.unsubscribeFromTopic('birthdays');
      print('Successfully unsubscribed from all notification topics');
    } catch (e) {
      print('Error unsubscribing from topics: $e');
    }
  }

  // Register dengan email dan password - DIMODIFIKASI UNTUK DEBUG
  Future<UserCredential> register(String email, String password) async {
    try {
      if (_isDebugMode) {
        print('DEBUG MODE: Mencoba registrasi dengan error handling minimal');

        // Skip validasi email untuk debug mode

        // Cek apakah user sudah ada (dengan error handling)
        try {
          final methods = await _auth.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            print(
                'WARNING: Email sudah terdaftar, tetapi melanjutkan untuk debug');
          }
        } catch (e) {
          print('Error checking email: $e - melanjutkan untuk debug');
        }

        // Registrasi dengan timeout pendek
        try {
          final userCredential = await _auth
              .createUserWithEmailAndPassword(
                email: email,
                password: password,
              )
              .timeout(Duration(seconds: 5));

          // Jangan kirim email verifikasi di debug mode
          print('DEBUG: User dibuat, email verifikasi TIDAK dikirim');

          return userCredential;
        } catch (e) {
          print('REGISTRATION ERROR: $e');

          // Fallback ke metode alternatif untuk debug
          print('DEBUG: Mencoba metode alternatif - Anonymous auth');
          final anonResult = await _auth.signInAnonymously();

          print('DEBUG: Registrasi berhasil dengan metode alternatif');
          return anonResult;
        }
      }

      // Kode produksi normal
      // Register user baru
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pastikan user baru tidak didaftarkan sebagai admin
      if (await _isAdmin(credential.user!.uid)) {
        await _auth.signOut();
        throw Exception('Invalid registration attempt');
      }

      // Kirim email verifikasi
      await credential.user!.sendEmailVerification();

      // Subscribe ke topics setelah registrasi berhasil
      await subscribeToNotificationTopics();

      return credential;
    } catch (e) {
      if (_isDebugMode) {
        print('DEBUG: Registration error ignored: $e');

        // Dalam mode debug, coba Anonymous auth jika error
        try {
          print('DEBUG: Fallback to anonymous auth after error');
          return await _auth.signInAnonymously();
        } catch (innerE) {
          print('DEBUG: Even anonymous auth failed: $innerE');
        }
      }

      throw Exception('Failed to register: $e');
    }
  }

  // Sign in dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Verifikasi bahwa user bukan admin - DILEWATI DI DEBUG MODE
      if (!_isDebugMode) {
        final isAdmin = await _isAdmin(userCredential.user!.uid);
        if (isAdmin) {
          await _auth.signOut();
          throw Exception('Admin tidak dapat login melalui aplikasi mobile');
        }
      }

      // Subscribe ke topics setelah login dengan Google berhasil
      await subscribeToNotificationTopics();

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Check if user is admin
  Future<bool> _isAdmin(String userId) async {
    if (_isDebugMode) {
      // Dalam debug mode, selalu asumsikan bukan admin
      return false;
    }

    try {
      final doc = await _firestore.collection('admins').doc(userId).get();
      return doc.exists && doc.data()?['status'] == 'active';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Check if user exists in Firestore
  Future<bool> isNewUser(String userId) async {
    if (_isDebugMode) {
      // Dalam debug mode, selalu asumsikan user baru
      return true;
    }

    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      // Jika user sudah ada di collection admins, throw error
      if (await _isAdmin(userId)) {
        throw Exception('Admin account detected');
      }

      return !docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    if (_isDebugMode) {
      // Dalam debug mode, selalu return 'user'
      return 'user';
    }

    try {
      if (await _isAdmin(userId)) return 'admin';

      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['role'] ?? 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('Starting logout process...');

      // Check current user's provider data
      final user = _auth.currentUser;
      if (user != null) {
        final isGoogleUser = user.providerData
            .any((userInfo) => userInfo.providerId == 'google.com');

        // If user is signed in with Google, sign out from Google
        if (isGoogleUser) {
          print('Signing out from Google...');
          await _googleSignIn.signOut();
        }

        // Unsubscribe from topics
        print('Unsubscribing from notification topics...');
        await unsubscribeFromNotificationTopics();
      }

      print('Signing out from Firebase...');
      await _auth.signOut();

      print('Logout successful');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user provider data
  List<String> get currentUserProviders {
    if (_auth.currentUser == null) return [];
    return _auth.currentUser!.providerData
        .map((userInfo) => userInfo.providerId)
        .toList();
  }

  // Stream untuk mendengarkan perubahan status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper method untuk validasi role
  Future<bool> validateUserRole(String userId) async {
    if (_isDebugMode) {
      // Dalam debug mode, selalu return true
      return true;
    }

    try {
      final role = await getUserRole(userId);
      return role == 'user'; // true jika user biasa, false jika admin
    } catch (e) {
      print('Error validating user role: $e');
      return false;
    }
  }
}
