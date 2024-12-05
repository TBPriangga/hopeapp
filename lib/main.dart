import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// View Models
import 'package:hopeapp/viewsModels/auth/login_viewmodel.dart';
import 'package:hopeapp/viewsModels/auth/register_viewmodel.dart';
import 'package:hopeapp/viewsModels/splash/splash_viewmodel.dart';
import 'package:hopeapp/viewsModels/home/birthday_viewmodel.dart';
import 'package:hopeapp/viewsModels/home/carousel_viewmodel.dart';
import 'package:hopeapp/viewsModels/youtube/youtube_viewmodel.dart';

// Services
import 'package:hopeapp/core/services/auth/auth_service.dart';
import 'package:hopeapp/core/services/youtube/youtube_service.dart';

// Routes
import 'app/routes/app_routes.dart';
import 'core/services/home/dailyWord_service.dart';
import 'viewsModels/auth/edit_profile_viewmodel.dart';
import 'viewsModels/dailyWords/dailyWordList_viewmodel.dart';
import 'viewsModels/dailyWords/dailyWord_viewmodel.dart';
import 'viewsModels/event/event_viewmodel.dart';
import 'viewsModels/sermon/sermon_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null);
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
        Provider<YouTubeService>(
          // Add this
          create: (_) => YouTubeService(),
        ),
        Provider<DailyWordService>(
          create: (_) => DailyWordService(),
        ),

        // ViewModels
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CarouselViewModel()),
        ChangeNotifierProvider(create: (_) => BirthdayViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => SermonViewModel()),
        ChangeNotifierProvider(
          create: (context) => YouTubeViewModel(
            youtubeService: context.read<YouTubeService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DailyWordViewModel(
            dailyWordService: context.read<DailyWordService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DailyWordListViewModel(
            dailyWordService: context.read<DailyWordService>(),
          ),
        ),
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'), // Indonesian
          Locale('en', 'US'), // English
        ],
        locale: const Locale('id', 'ID'),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
