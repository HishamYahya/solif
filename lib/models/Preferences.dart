import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences with ChangeNotifier {
  bool _isDarkMode = true;
  String _language = 'ar';
  SharedPreferences sharedPreferences;

  Preferences() {
    init();
  }

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('darkMode')) {
      _isDarkMode = sharedPreferences.get('darkMode');
    } else {
      sharedPreferences.setBool('darkMode', true);
    }
    if (sharedPreferences.containsKey('language')) {
      _language = sharedPreferences.get('language');
    } else {
      sharedPreferences.setString('language', 'ar');
    }
    notifyListeners();
  }

  get isArabic => _language == 'ar';
  get isEnglish => _language == 'en';

  set language(String lang) {
    _language = lang;
    sharedPreferences.setString('language', lang);

    notifyListeners();
  }

  get darkMode => _isDarkMode;

  set darkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    sharedPreferences.setBool('darkMode', isDarkMode);
    notifyListeners();
  }
}
