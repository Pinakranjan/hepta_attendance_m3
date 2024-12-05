import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../themes/dark_theme.dart';
import '../themes/light_theme.dart';

class ChangeThemeButtonWidgetV2 extends StatelessWidget {
  const ChangeThemeButtonWidgetV2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<CustomThemeProvider>(context);

    return ThemeSwitcher(
      builder: (context) {
        return DayNightSwitcher(
          isDarkModeEnabled: themeState.getDarkTheme,
          onStateChanged: (bool darkMode) {
            // setState(() {
            //   themeState.setDarkTheme = darkMode;
            // });

            // var service = await ThemeService.instance
            //   ..save(darkMode ? 'light' : 'dark');
            // var theme = service.getByName(themeName);
            themeState.setDarkTheme = darkMode;
            ThemeSwitcher.of(context).changeTheme(theme: darkMode ? darkTheme : lightTheme, isReversed: darkMode);

            // Future.delayed(const Duration(seconds: 1)).then((_) => {
            //       themeState.setDarkTheme = darkMode,
            //     });
          },
          // moonColor: Colors.white,
          // starsColor: Colors.blue.shade300,
          // cloudsColor: Colors.black,
          // cratersColor: Colors.white,
        );
      },
    );
  }
}
