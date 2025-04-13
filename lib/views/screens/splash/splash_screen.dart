import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewsModels/splash/splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil initializeApp setelah widget selesai di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().initializeApp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final Size screenSize = MediaQuery.of(context).size;

    return Consumer<SplashViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF132054),
                  Color(0xFF2B478A),
                  Color(0xFF132054),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Logo di tengah
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gambar logo dengan ukuran responsif
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenSize.width * 0.7,
                            maxHeight: screenSize.height * 0.5,
                          ),
                          child: Image.asset(
                            'assets/logo/hope_logo_old.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Loading indicator
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Versi aplikasi di bagian bawah
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Versi ${viewModel.appVersion}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
