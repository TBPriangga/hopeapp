import 'package:flutter/material.dart';
import 'package:hopeapp/views/screens/sermons/detail_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/save_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/sermon_screen.dart';
import '../../views/screens/auth/complete_register_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/event/screen/detail_event_screen.dart';
import '../../views/screens/event/screen/empty_event_screen.dart';
import '../../views/screens/event/screen/event_screen.dart';
import '../../views/screens/form/baptis_form.dart';
import '../../views/screens/form/conseling_form.dart';
import '../../views/screens/form/discipleship_form.dart';
import '../../views/screens/form/offering_info.dart';
import '../../views/screens/form/prayer_request.dart';
import '../../views/screens/form/wedding_form.dart';
import '../../views/screens/notifications/notifications_screen.dart';
import '../../views/screens/profile/screen/change_password.dart';
import '../../views/screens/profile/screen/edit_profile_screen.dart';
import '../../views/screens/profile/screen/profile_screen.dart';
import '../../views/screens/splash/splash_screen.dart';
import '../../views/screens/home/screen/home_screen.dart';
import '../../views/screens/youtube/youtube_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sermon = '/sermon';
  static const String detailSermon = '/detail-sermon';
  static const String saveSermon = '/save-sermon';
  static const String notification = '/notification';
  static const String emptyEvent = '/empty-event';
  static const String event = '/event';
  static const String eventDetail = '/event-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String completeProfile = '/complete-profile';
  static const String prayerRequest = '/prayer-request';
  static const String baptismRegistration = '/baptism-registration';
  static const String weddingRegistration = '/wedding-registration';
  static const String offeringInfo = '/offering-info';
  static const String youtube = '/youtube';
  static const String counseling = '/counseling';
  static const String discipleship = '/discipleship';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    sermon: (context) => const SermonScreen(),
    detailSermon: (context) => const DetailSermonScreen(),
    saveSermon: (context) => const SaveSermonScreen(),
    notification: (context) => const NotificationScreen(),
    emptyEvent: (context) => const EmptyEventScreen(),
    event: (context) => const EventScreen(),
    eventDetail: (context) => const EventDetailScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    completeProfile: (context) => CompleteProfileScreen(
          userData: ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>,
        ),
    prayerRequest: (context) => const PrayerRequestScreen(),
    baptismRegistration: (context) => const BaptismRegistrationScreen(),
    weddingRegistration: (context) => const WeddingRegistrationScreen(),
    offeringInfo: (context) => const OfferingInfoScreen(),
    youtube: (context) => const YouTubeScreen(),
    counseling: (context) => const CounselingScreen(),
    discipleship: (context) => const DiscipleshipScreen(),
  };
}
