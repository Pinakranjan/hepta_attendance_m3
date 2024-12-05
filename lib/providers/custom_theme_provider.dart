import 'package:flutter/material.dart';

import '../services/dark_theme_prefs.dart';

class CustomThemeProvider extends ChangeNotifier {
  final DarkThemePrefs darkThemePrefs = DarkThemePrefs();

  bool _darkTheme = false;
  bool get getDarkTheme => _darkTheme;

  set setDarkTheme(bool value) {
    _darkTheme = value;
    darkThemePrefs.setDarkTheme(value);
    notifyListeners();
  }
}
