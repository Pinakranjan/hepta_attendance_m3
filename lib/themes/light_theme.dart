import 'package:flutter/material.dart';
import '../utils/color_constraints.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: ColorConfig.lightMain,
  // primaryColor: Colors.grey.shade300,
  primaryColorDark: ColorConfig.darkMain,
  chipTheme: ChipThemeData(
    backgroundColor: ColorConfig.darkChip,
    labelStyle: TextStyle(color: ColorConfig.lightChipFont, fontSize: 18, fontWeight: FontWeight.w400),
    shadowColor: ColorConfig.darkMain,
    elevation: 6,
    // iconTheme: const IconThemeData(color: Colors.transparent),
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2),
    ),
    side: BorderSide(
      color: ColorConfig.darkMain,
      width: 2,
    ),
    checkColor: MaterialStateProperty.all(ColorConfig.lightMain),
    // fillColor: MaterialStateProperty.all(ColorConfig.darkMain),
  ),
  textTheme: TextTheme(
    //Primarily Used for Check Box
    bodyMedium: TextStyle(
      color: ColorConfig.darkMain,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    //Primarily Used for Text Box
    titleMedium: TextStyle(decoration: TextDecoration.none, decorationThickness: 0, fontSize: 16, fontWeight: FontWeight.w500, color: ColorConfig.darkMain),
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
      backgroundColor: ColorConfig.darkChip,
      foregroundColor: ColorConfig.lightButtonFont,
      fixedSize: const Size(150, 35),
      elevation: 5.0,
      shadowColor: ColorConfig.darkMain,
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
    // outlineBorder: BorderSide(width: 4, color: ColorConfig.lightBorderEnabled),
    // border: OutlineInputBorder(
    //   borderRadius: const BorderRadius.all(Radius.circular(9.0)),
    //   borderSide: BorderSide(width: 1.5, color: ColorConfig.lightBorderEnabled),
    // ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(9.0)),
      borderSide: BorderSide(width: 1.5, color: ColorConfig.lightBorderEnabled),
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
      borderSide: BorderSide(width: 1.0, color: ColorConfig.lightBorderDisabled),
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
      color: ColorConfig.lightHintColor,
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
      return TextStyle(color: ColorConfig.lightLabelColor, fontWeight: FontWeight.bold, letterSpacing: 1.1, overflow: TextOverflow.clip);
    }),
    floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.error)) {
        return TextStyle(color: ColorConfig.focusedFloatingLabelInValid);
      } else if (states.contains(MaterialState.focused)) {
        return TextStyle(color: ColorConfig.focusedFloatingLabelValid);
      } else {
        if (states.contains(MaterialState.disabled)) {
          return TextStyle(color: ColorConfig.lightFloatingLabelDisabled);
        } else {
          return TextStyle(color: ColorConfig.lightFloatingLabelEnabled);
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
  //   circularTrackColor: ColorConfig.lightProgressIndicatorTrack,
  //   linearTrackColor: ColorConfig.lightProgressIndicatorTrack,
  //   color: ColorConfig.lightProgressIndicator,
  // ),
);
