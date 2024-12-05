// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ColorConfig {
  static Color light = Colors.grey.shade300;
  // static Color light = Color.fromARGB(255, 243, 195, 38);
  static Color dark = Colors.grey.shade900;

  static Color lightMain = light;
  static Color darkMain = dark;

  static Color lightChip = light;
  static Color darkChip = Colors.black.withOpacity(0.7);

  static Color lightChipFont = light;
  static Color darkChipFont = Colors.black.withOpacity(0.8);

  static Color lightButtonFont = light;
  static Color darkButtonFont = Colors.black.withOpacity(0.8);

  static Color darkAppbarFont = light;
  static Color lightAppbarFont = Colors.black.withOpacity(0.8);

  static Color lightFontEnabled = light;
  static Color darkFontEnabled = dark;
  static Color lightFontDisabled = Colors.black.withOpacity(0.6);
  static Color darkFontDisabled = Colors.grey.shade700;

  static Color darkBorderValid = Colors.grey.shade400;
  static Color lightBorderValid = Colors.black.withOpacity(0.8);
  static Color focusedBorderValid = Colors.blue;
  static Color focusedBorderInValid = Colors.red;

  static Color darkBorderDisabled = Colors.grey.shade700;
  static Color darkBorderEnabled = Colors.grey.shade400;

  static Color lightBorderEnabled = Colors.black.withOpacity(0.8);
  static Color lightBorderDisabled = Colors.black.withOpacity(0.5);

  static Color darkHintColor = Colors.grey.shade700;
  static Color lightHintColor = Colors.black.withOpacity(0.30);

  static Color darkLabelColor = Colors.grey.shade700;
  static Color lightLabelColor = Colors.black.withOpacity(0.50);

  static Color focusedFloatingLabelValid = Colors.blue;
  static Color focusedFloatingLabelInValid = Colors.red;

  static Color darkFloatingLabelEnabled = Colors.grey.shade400;
  static Color darkFloatingLabelDisabled = Colors.grey.shade700;

  static Color lightFloatingLabelEnabled = Colors.black.withOpacity(0.8);
  static Color lightFloatingLabelDisabled = Colors.black.withOpacity(0.5);

  static Color textSelectionValid = Colors.blue;

  static Color darkProgressIndicatorTrack = Colors.blueAccent;
  static Color darkProgressIndicator = light;
  static Color lightProgressIndicatorTrack = light;
  static Color lightProgressIndicator = Colors.blue;
}
