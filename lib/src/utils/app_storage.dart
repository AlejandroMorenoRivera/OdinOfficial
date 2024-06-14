import 'package:flutter/material.dart';

class AppStorage {
  static Color? textPrimaryColor;
  static Color? iconColorPrimaryDark;
  static Color? scaffoldBackground;
  static Color? backgroundColor;
  static Color? backgroundSecondaryColor;
  static Color? appColorPrimaryLightColor;
  static Color? textSecondaryColor;
  static Color? appBarColor;
  static Color? iconColor;
  static Color? iconSecondaryColor;
  static Color? cardColor;

  AppStorage() {
    textPrimaryColor = const Color(0xFF212121);
    iconColorPrimaryDark = const Color(0xFF212121);
    scaffoldBackground = const Color(0xFFEBF2F7);
    backgroundColor = Colors.black;
    backgroundSecondaryColor = const Color(0xFF131d25);
    appColorPrimaryLightColor = const Color(0xFFF9FAFF);
    textSecondaryColor = const Color(0xFF5A5C5E);
    appBarColor = Colors.white;
    iconColor = const Color(0xFF212121);
    iconSecondaryColor = const Color(0xFFA8ABAD);
    cardColor = const Color(0xFF191D36);
  }
}
