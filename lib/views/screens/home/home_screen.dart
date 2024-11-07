import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';
import '../sermons/sermon_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF132054),
        actions: [
          IconButton(
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Home Screen',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Tambahkan Card untuk Sermon
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SermonScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.video_library,
                        size: 48,
                        color: Color(0xFF132054),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sermon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF132054),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
