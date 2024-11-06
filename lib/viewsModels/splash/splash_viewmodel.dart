import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initializeApp(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // Cek status auth
      User? user = FirebaseAuth.instance.currentUser;

      if (context.mounted) {
        if (user != null) {
          // User sudah login, navigasi ke home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          // User belum login, navigasi ke login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Handle error
    }
  }
}
