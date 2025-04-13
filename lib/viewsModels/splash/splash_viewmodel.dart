import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../app/routes/app_routes.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _appVersion = '';

  // Getter untuk versi aplikasi
  String get appVersion => _appVersion;

  Future<void> initializeApp(BuildContext context) async {
    try {
      // Dapatkan informasi versi aplikasi (hanya versi tanpa build number)
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion =
          packageInfo.version; // Tampilkan hanya versi tanpa build number
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      // Cek status auth
      User? user = _auth.currentUser;

      if (context.mounted) {
        if (user != null) {
          // PERBAIKAN: Cek juga apakah email sudah diverifikasi
          // Reload user untuk mendapatkan status verifikasi terbaru
          await user.reload();
          user = _auth.currentUser; // Re-assign setelah reload

          bool isVerified = user?.emailVerified ?? false;

          if (isVerified) {
            // Email sudah diverifikasi, navigasi ke home
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else {
            // Email belum diverifikasi, logout dan navigasi ke login
            await _auth.signOut();
            Navigator.pushReplacementNamed(context, AppRoutes.login);

            // Tampilkan pesan ke user jika perlu
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Email belum diverifikasi. Silakan login dan verifikasi email Anda.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          // User belum login, navigasi ke login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      print('Error initializing app: $e');

      // Handle error - arahkan ke login pada kasus error
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }
}
