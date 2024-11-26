import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login dengan email dan password
  Future<UserCredential> login(String email, String password) async {
    try {
      // Login dengan Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifikasi bahwa user bukan admin
      final isAdmin = await _isAdmin(credential.user!.uid);
      if (isAdmin) {
        await _auth.signOut();
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      return credential;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Register dengan email dan password
  Future<UserCredential> register(String email, String password) async {
    try {
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

      return credential;
    } catch (e) {
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

      // Verifikasi bahwa user bukan admin
      final isAdmin = await _isAdmin(userCredential.user!.uid);
      if (isAdmin) {
        await _auth.signOut();
        throw Exception('Admin tidak dapat login melalui aplikasi mobile');
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Check if user is admin
  Future<bool> _isAdmin(String userId) async {
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
    try {
      final role = await getUserRole(userId);
      return role == 'user'; // true jika user biasa, false jika admin
    } catch (e) {
      print('Error validating user role: $e');
      return false;
    }
  }
}
