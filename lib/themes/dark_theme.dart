import 'package:flutter/material.dart';

import '../utils/color_constraints.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: ColorConfig.darkMain,
  // primaryColor: Colors.grey.shade300,
  primaryColorDark: ColorConfig.lightMain,
  chipTheme: ChipThemeData(
    backgroundColor: ColorConfig.lightChip,
    labelStyle: TextStyle(color: ColorConfig.darkChipFont, fontSize: 18, fontWeight: FontWeight.w500),
    shadowColor: ColorConfig.lightMain,
    elevation: 6,
    // iconTheme: const IconThemeData(color: Colors.red),
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2),
    ),
    side: BorderSide(
      color: ColorConfig.lightMain,
      width: 2,
    ),
    checkColor: MaterialStateProperty.all(ColorConfig.darkMain),
    // fillColor: MaterialStateProperty.all(ColorConfig.lightMain),
  ),
  textTheme: TextTheme(
    //Primarily Used for Check Box
    bodyMedium: TextStyle(
      color: ColorConfig.lightMain,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    //Primarily Used for Text Box
    titleMedium: TextStyle(decoration: TextDecoration.none, decorationThickness: 0, fontSize: 16, fontWeight: FontWeight.w500, color: ColorConfig.lightMain),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.red.shade900,
    foregroundColor: ColorConfig.lightMain,
    elevation: 20,
    hoverColor: Colors.red.shade500,
    splashColor: Colors.tealAccent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorConfig.lightChip,
      foregroundColor: ColorConfig.darkButtonFont,
      fixedSize: const Size(150, 35),
      elevation: 5.0,
      shadowColor: ColorConfig.lightMain,
      //Don't give color to border side
      side: const BorderSide(width: 1, color: Colors.transparent),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(
        color: ColorConfig.focusedBorderInValid,
      ),
    ),
    // border: const OutlineInputBorder(
    //   borderRadius: BorderRadius.all(Radius.circular(9.0)),
    //   borderSide: BorderSide(),
    // ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(color: ColorConfig.darkBorderEnabled),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(
        width: 2.2,
        color: ColorConfig.focusedBorderValid,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(
        width: 2.2,
        color: ColorConfig.focusedBorderInValid,
      ),
    ),
    // focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.7, color: Colors.red)),
    disabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(width: 0.7, color: ColorConfig.darkBorderDisabled),
    ),
    prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
      // if (states.contains(MaterialState.error)) {
      //   return Colors.red;
      // }
      if (states.contains(MaterialState.focused)) {
        if (states.contains(MaterialState.error)) {
          return Colors.red;
        } else {
          return Colors.blue;
        }
      } else {
        return Colors.grey.shade700;
      }
    }),
    hintStyle: TextStyle(
      color: ColorConfig.darkHintColor,
      letterSpacing: 1.5,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.clip,
    ),
    labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
      // final Color color = states.contains(MaterialState.error)
      //     ? (Theme.of(context).colorScheme.secondary) //Theme.of(context).colorScheme.error
      //     : redErrorText == true
      //         ? Colors.red
      //         : (Theme.of(context).colorScheme.secondary);
      return TextStyle(color: ColorConfig.darkLabelColor, fontWeight: FontWeight.bold, letterSpacing: 1.1, overflow: TextOverflow.clip);
    }),
    floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.error)) {
        return TextStyle(color: ColorConfig.focusedFloatingLabelInValid);
      } else if (states.contains(MaterialState.focused)) {
        return TextStyle(color: ColorConfig.focusedFloatingLabelValid);
      } else {
        if (states.contains(MaterialState.disabled)) {
          return TextStyle(color: ColorConfig.darkFloatingLabelDisabled);
        } else {
          return TextStyle(color: ColorConfig.darkFloatingLabelEnabled);
        }
      }
    }),
  ),
  textSelectionTheme: TextSelectionThemeData(
    //Need one for error selection
    selectionColor: ColorConfig.textSelectionValid.withOpacity(.5),
    cursorColor: ColorConfig.textSelectionValid.withOpacity(.8),
    selectionHandleColor: ColorConfig.textSelectionValid,
  ),
  // progressIndicatorTheme: ProgressIndicatorThemeData(
  //   circularTrackColor: ColorConfig.darkProgressIndicatorTrack,
  //   color: ColorConfig.darkProgressIndicator,
  // ),
  // dialogTheme: DialogTheme(
  //     // contentTextStyle: TextStyle(color: Colors.white),
  //     titleTextStyle: TextStyle(color: ColorConfig.lightAppbarFont),
  //     backgroundColor: ColorConfig.lightMain,
  //     elevation: 10),
);
