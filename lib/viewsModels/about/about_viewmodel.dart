import 'package:flutter/material.dart';

class AboutViewModel extends ChangeNotifier {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  String get youtubeSejarahUrl => 'https://www.youtube.com/watch?v=xkOOmwk-BWI';
}
