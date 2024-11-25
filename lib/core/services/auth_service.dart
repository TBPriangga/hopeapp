// services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login dengan email dan password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Register dengan email dan password
  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Check if user exists in Firestore
  Future<bool> isNewUser(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return !docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
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
}
