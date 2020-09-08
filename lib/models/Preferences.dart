import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/constants.dart';

class Preferences with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'ar';
  SharedPreferences sharedPreferences;
  Map<String, Color> currentColors = kOurColorsLight;

  Preferences() {
    init();
  }

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('darkMode')) {
      darkMode = sharedPreferences.get('darkMode');
    } else {
      sharedPreferences.setBool('darkMode', true);
    }
    if (sharedPreferences.containsKey('language')) {
      language = sharedPreferences.get('language');
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
    currentColors = isDarkMode ? kOurColorsDark : kOurColorsLight;
    sharedPreferences.setBool('darkMode', isDarkMode);
    notifyListeners();
  }
}
