// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// View Models
import 'package:hopeapp/viewsModels/auth/login_viewmodel.dart';
import 'package:hopeapp/viewsModels/auth/register_viewmodel.dart';
import 'package:hopeapp/viewsModels/splash/splash_viewmodel.dart';

// Services
import 'package:hopeapp/core/services/auth_service.dart';

// Routes
import 'app/routes/app_routes.dart';
import 'viewsModels/auth/edit_profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),

        // ViewModels
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Hope App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: const Color(0xFF132054),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF132054),
            primary: const Color(0xFF132054),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
