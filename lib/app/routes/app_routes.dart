import 'package:flutter/material.dart';
import 'package:hopeapp/views/screens/form/childDedication.dart';
import 'package:hopeapp/views/screens/sermons/detail_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/save_sermon_screen.dart';
import 'package:hopeapp/views/screens/sermons/sermon_screen.dart';
import '../../views/screens/about/about_screen.dart';
import '../../views/screens/auth/change_password_screen.dart';
import '../../views/screens/auth/complete_register_screen.dart';
import '../../views/screens/auth/fotgot_password_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/dailyword/dailyWord_listScreen.dart';
import '../../views/screens/dailyword/dailyWord_screen.dart';
import '../../views/screens/discipleship/discipleship.dart';
import '../../views/screens/event/screen/detail_event_screen.dart';
import '../../views/screens/event/screen/empty_event_screen.dart';
import '../../views/screens/event/screen/event_screen.dart';
import '../../views/screens/form/baptis_form.dart';
import '../../views/screens/form/conseling_form.dart';
import '../../views/screens/form/discipleship_form.dart';
import '../../views/screens/form/form_screen.dart';
import '../../views/screens/form/offering_info.dart';
import '../../views/screens/form/prayer_request.dart';
import '../../views/screens/form/wedding_form.dart';
import '../../views/screens/notifications/notifications_screen.dart';
import '../../views/screens/notifications/notifications_test_screen.dart';
import '../../views/screens/offering/offering_report_screen.dart';
import '../../views/screens/profile/screen/edit_profile_screen.dart';
import '../../views/screens/profile/screen/profile_screen.dart';
import '../../views/screens/sermons/series_list_screen.dart';
import '../../views/screens/sermons/sermon_series_detail_screen.dart';
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
  static const String form = '/form';
  static const String dailyWord = '/daily-word';
  static const String dailyWordList = '/daily-word-list';
  static const String about = '/about';
  static const String discipleshipClass = '/discipleship-class';
  static const String offeringReport = '/offering-report';
  static const String sermonSeries = '/sermon-series';
  static const String sermonSeriesDetail = '/sermon-series-detail';
  static const String notificationTest = '/notification-test';
  static const String forgotPassword = '/forgot-password';
  static const String childDedication = '/child-dedication';

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
    form: (context) => const FormScreen(),
    dailyWord: (context) => const DailyWordScreen(),
    dailyWordList: (context) => const DailyWordListScreen(),
    about: (context) => const AboutScreen(),
    discipleshipClass: (context) => const DiscipleshipClassScreen(),
    offeringReport: (context) => const OfferingReportScreen(),
    sermonSeries: (context) => const SermonSeriesScreen(),
    sermonSeriesDetail: (context) => const SermonSeriesDetailScreen(),
    notificationTest: (context) => const NotificationTestScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    childDedication: (context) => const ChildDedicationScreen(),
  };
}
