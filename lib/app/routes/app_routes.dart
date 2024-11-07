import 'package:flutter/material.dart';
import 'package:hopeapp/views/screens/sermons/detail_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/save_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/sermon_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/splash/splash_screen.dart';
import '../../views/screens/home/home_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sermon = '/sermon';
  static const String detailSermon = '/detail-sermon';
  static const String saveSermon = '/save-sermon';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    sermon: (context) => const SermonScreen(),
    detailSermon: (context) => const DetailSermonScreen(),
    saveSermon: (context) => const SaveSermonScreen(),
  };
}
