import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:hopeapp/core/services/notifications/notifications_service.dart';

// Routes
import 'app/routes/app_routes.dart';
import 'core/services/firestore_service.dart';
import 'core/services/home/dailyWord_service.dart';
import 'core/services/notifications/notifications_service.dart';
import 'core/services/sermon/sermon_service.dart';
import 'viewsModels/about/about_viewmodel.dart';
import 'viewsModels/auth/edit_profile_viewmodel.dart';
import 'viewsModels/auth/forgot_password_viewmodel.dart';
import 'viewsModels/dailyWords/dailyWordList_viewmodel.dart';
import 'viewsModels/dailyWords/dailyWord_viewmodel.dart';
import 'viewsModels/event/event_viewmodel.dart';
import 'viewsModels/notifications/notifications_viewmodel.dart';
import 'viewsModels/offering/offering_report_viewModel.dart';
import 'viewsModels/sermon/sermon_viewmodel.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Pembersihan pendaftaran yang tertunda
Future<void> cleanupPendingRegistrations() async {
  try {
    // Cek SharedPreferences untuk registrasi yang tertunda
    final prefs = await SharedPreferences.getInstance();
    final pendingId = prefs.getString('pending_registration_id');
    final expiresAt = prefs.getInt('pending_registration_expires');
    final pendingEmail = prefs.getString('pending_registration_email');
    final pendingPassword = prefs.getString('pending_registration_password');

    if (pendingId != null && expiresAt != null) {
      print('Found pending registration: $pendingId, email: $pendingEmail');

      // Cek apakah sudah kadaluarsa
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now >= expiresAt) {
        print('Pending registration expired, cleaning up on app start');

        // Coba hapus user yang tidak terverifikasi
        if (pendingEmail != null && pendingPassword != null) {
          try {
            print('Attempting to login with: $pendingEmail');

            // Coba sign in dengan email/password untuk mendapatkan akses ke akun
            try {
              final credential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: pendingEmail, password: pendingPassword);

              if (credential.user != null) {
                print('Successfully signed in as: ${credential.user!.email}');

                // Reload user untuk mendapatkan status terbaru
                await credential.user!.reload();
                print('User reloaded');

                // Cek apakah email sudah diverifikasi
                if (!credential.user!.emailVerified) {
                  print('Email not verified, deleting user');

                  // Hapus akun jika belum diverifikasi
                  await credential.user!.delete();
                  print('Successfully deleted unverified user: $pendingEmail');
                } else {
                  print('User already verified, not deleting: $pendingEmail');
                }

                // Sign out
                await FirebaseAuth.instance.signOut();
                print('Signed out after cleanup');
              }
            } catch (signInError) {
              print('Error signing in to delete user: $signInError');

              // Jika gagal sign in karena password salah, coba cek dengan fetchSignInMethodsForEmail
              // untuk melihat apakah email masih terdaftar
              try {
                final methods = await FirebaseAuth.instance
                    .fetchSignInMethodsForEmail(pendingEmail);
                if (methods.isEmpty) {
                  print('Email not registered anymore: $pendingEmail');
                } else {
                  print(
                      'Email still registered but cannot delete: $pendingEmail, methods: $methods');
                  // Tidak bisa menghapus karena tidak bisa login
                }
              } catch (methodError) {
                print('Error checking sign-in methods: $methodError');
              }
            }
          } catch (e) {
            print('Error during cleanup: $e');
          }
        }

        // Hapus data dari SharedPreferences
        await prefs.remove('pending_registration_id');
        await prefs.remove('pending_registration_expires');
        await prefs.remove('pending_registration_email');
        await prefs.remove('pending_registration_password');
        print('Cleared pending registration data from SharedPreferences');
      } else {
        // Masih valid, tampilkan berapa lama lagi berlaku
        final remainingMillis = expiresAt - now;
        print(
            'Pending registration still valid for ${remainingMillis / 1000} seconds');
      }
    }
  } catch (e) {
    print('Error checking pending registrations: $e');
  }
}

// Menonaktifkan Firebase App Check untuk debugging
Future<void> disableAppCheckForDebugging() async {
  // Hanya menonaktifkan Firebase App Check dalam mode debug
  if (kDebugMode) {
    print('DEVELOPMENT MODE: Firebase App Check dinonaktifkan untuk debugging');
    print('=================================================');
    print('| FIREBASE APP CHECK DINONAKTIFKAN UNTUK DEBUGGING |');
    print('| FITUR VERIFIKASI EMAIL JUGA DILEWATI            |');
    print('=================================================');
  } else {
    // Aktifkan App Check di lingkungan produksi
    try {
      await FirebaseAppCheck.instance.activate(
        // Gunakan Android Provider dan Debug Provider berdasarkan konfigurasi Anda
        androidProvider: AndroidProvider.playIntegrity,
      );
      print('PRODUCTION MODE: Firebase App Check diaktifkan');
    } catch (e) {
      print('Error activating Firebase App Check: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
  print('Background message data: ${message.data}');
}

Future<void> requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  final token = await messaging.getToken();
  print('FCM Token: $token');

  await messaging.subscribeToTopic('daily_word');
  await messaging.subscribeToTopic('events');
  await messaging.subscribeToTopic('birthdays');
}

Future<void> setupForegroundNotificationHandling() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      String channelId;
      String soundName = 'notification_sound';

      switch (message.data['type']) {
        case 'daily_word':
          channelId = 'daily_word_channel';
          break;
        case 'event':
          channelId = 'event_channel';
          break;
        case 'birthday':
          channelId = 'birthday_channel';
          break;
        default:
          channelId = 'default_channel';
      }

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            icon: '@drawable/notification_icon',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound(soundName),
            enableVibration: true,
            enableLights: true,
            visibility: NotificationVisibility.public,
            playSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  });
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/notification_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      print('Notification tapped: ${details.payload}');
      _handleNotificationTap(details.payload);
    },
  );
}

Future<void> setupNotificationChannels() async {
  const dailyWordChannel = AndroidNotificationChannel(
    'daily_word_channel',
    'Renungan Harian',
    description: 'Notifikasi untuk renungan harian',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    enableVibration: true,
  );

  const eventChannel = AndroidNotificationChannel(
    'event_channel',
    'Event Notifications',
    description: 'Notifikasi untuk event gereja',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    enableVibration: true,
  );

  const birthdayChannel = AndroidNotificationChannel(
    'birthday_channel',
    'Birthday Notifications',
    description: 'Notifikasi untuk ulang tahun jemaat',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    enableVibration: true,
  );

  final platform =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await platform?.createNotificationChannel(dailyWordChannel);
  await platform?.createNotificationChannel(eventChannel);
  await platform?.createNotificationChannel(birthdayChannel);
}

Future<void> setupTerminatedStateNotificationHandler() async {
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  if (message.data['type'] == 'event' && message.data['eventId'] != null) {
    navigatorKey.currentState?.pushNamed(
      AppRoutes.eventDetail,
      arguments: message.data['eventId'],
    );
  }
}

void _handleNotificationError(dynamic error) {
  print('Notification Error: $error');
}

void _handleNotificationTap(String? payload) {
  if (payload != null) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload));

      switch (data['type']) {
        case 'event':
          if (data['eventId'] != null) {
            navigatorKey.currentState?.pushNamed(
              AppRoutes.eventDetail,
              arguments: data['eventId'],
            );
          }
          break;
        case 'sermon':
          if (data['sermonId'] != null) {
            navigatorKey.currentState?.pushNamed(
              AppRoutes.detailSermon,
              arguments: data['sermonId'],
            );
          }
          break;
        case 'announcement':
          navigatorKey.currentState?.pushNamed(AppRoutes.notification);
          break;
        default:
          print('Unknown notification type: ${data['type']}');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }
}

void setupFCMTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService().updateUserFCMToken(user.uid, token);
    }
  });
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Inisialisasi Firebase
    await Firebase.initializeApp();

    // Aktifkan/nonaktifkan App Check berdasarkan mode
    await disableAppCheckForDebugging();

    // Bersihkan pendaftaran yang tertunda
    await cleanupPendingRegistrations();

    await initializeDateFormatting('id_ID', null);
    await requestNotificationPermissions();

    tz.initializeTimeZones();
    final jakartaTimeZone = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(jakartaTimeZone);

    await initializeLocalNotifications();
    await setupNotificationChannels();
    await setupForegroundNotificationHandling();
    await setupTerminatedStateNotificationHandler();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    setupFCMTokenRefresh();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    _handleNotificationError(e);
    print('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<YouTubeService>(create: (_) => YouTubeService()),
        Provider<DailyWordService>(create: (_) => DailyWordService()),
        Provider<SermonService>(create: (_) => SermonService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CarouselViewModel()),
        ChangeNotifierProvider(create: (_) => BirthdayViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => OfferingReportViewModel()),
        ChangeNotifierProvider(
          create: (context) => SermonViewModel(
            sermonService: context.read<SermonService>(),
          ),
        ),
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
        ChangeNotifierProvider(create: (_) => AboutViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        locale: const Locale('id', 'ID'),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
