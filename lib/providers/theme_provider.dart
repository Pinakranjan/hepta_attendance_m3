// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../services/dark_theme_prefs.dart';

class CustomThemes {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        // icon themes are not working for app bar
        // actionsIconTheme: IconThemeData(color: isDarkTheme ? Colors.yellow : Colors.blue),
        // iconTheme: IconThemeData(color: isDarkTheme ? Colors.cyan : Colors.black87),
        titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: isDarkTheme ? Colors.yellow : Colors.black87),
      ),
      scaffoldBackgroundColor: isDarkTheme ? Colors.grey.shade900 : Colors.yellow,
      // indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      primaryColor: isDarkTheme ? Colors.black : Colors.grey.shade300,
      primaryColorDark: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.7),
      primaryColorLight: isDarkTheme ? Colors.black : Colors.yellow,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.9),
          foregroundColor: isDarkTheme ? Colors.black.withOpacity(0.9) : Colors.yellow,
          fixedSize: Size(150, 35),
          elevation: 5.0,
          shadowColor: isDarkTheme ? Colors.white : Colors.grey.shade900,
          side: BorderSide(color: isDarkTheme ? Colors.yellow : Colors.grey.withOpacity(0.8), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            colorScheme: isDarkTheme ? const ColorScheme.dark() : const ColorScheme.light(),
          ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Color(0xFFC79822)),
        trackColor: MaterialStateProperty.all(Color(0x667B5A07)),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(isDarkTheme ? Colors.black.withOpacity(0.7) : Colors.yellow),
        fillColor: MaterialStateProperty.all(isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.7)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(Color(0xFFD8A21B)),
      ),
      // primaryTextTheme: Typography(platform: TargetPlatform.iOS).white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      // iconTheme: IconThemeData(color: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.7)),
      chipTheme: ChipThemeData(
        backgroundColor: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.7),
      ),
      dialogTheme: DialogTheme(
        contentTextStyle: TextStyle(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        // menuStyle: MenuStyle(),
        textStyle: TextStyle(fontSize: 14),
      ),
      listTileTheme: ListTileThemeData(
          textColor: isDarkTheme ? Colors.yellow : Colors.black,
          iconColor: isDarkTheme ? Colors.yellow : Colors.black.withOpacity(0.6),
          selectedTileColor: isDarkTheme ? Colors.yellow : Colors.black26,
          titleTextStyle: TextStyle(color: isDarkTheme ? Colors.yellow : Colors.black),
          subtitleTextStyle: TextStyle(
            inherit: true,
            color: isDarkTheme ? Colors.yellow.shade200 : Colors.pink,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.italic,
          )),
      // drawerTheme: DrawerThemeData(scrimColor: Colors.blue, backgroundColor: Colors.green)
    );
  }
}

class CustomThemeProvider extends ChangeNotifier {
  final DarkThemePrefs darkThemePrefs = DarkThemePrefs();

  bool _darkTheme = false;
  bool get getDarkTheme => _darkTheme;

  set setDarkTheme(bool value) {
    _darkTheme = value;
    darkThemePrefs.setDarkTheme(value);
    notifyListeners(); // Flickering
  }
}

// class MyThemes {
//   static final darkTheme = ThemeData(
//     scaffoldBackgroundColor: Colors.grey.shade900,
//     colorScheme: ColorScheme.dark(),
//     primaryColorDark: Colors.white,
//     primaryColorLight: Colors.black,
//     elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//             elevation: 5,
//             backgroundColor: Colors.yellow,
//             foregroundColor: Colors.grey.shade700,
//             side: BorderSide(color: Colors.grey.withOpacity(0.8), width: 1))),
//   );
//   static final lightTheme = ThemeData(
//     scaffoldBackgroundColor: Colors.yellow,
//     colorScheme: ColorScheme.light(),
//     primaryColorDark: Colors.black.withOpacity(0.7),
//     primaryColorLight: Colors.white,
//     elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//             elevation: 5,
//             backgroundColor: Colors.grey.shade900,
//             foregroundColor: Colors.yellow,
//             side: BorderSide(color: Colors.grey.withOpacity(0.8), width: 1))),
//   );
// }
