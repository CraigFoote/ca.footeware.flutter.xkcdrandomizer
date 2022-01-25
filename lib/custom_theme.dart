import 'package:flutter/material.dart';

class CustomTheme {
  static var currentTheme = lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xffd8dee9),
        secondary: const Color(0xffe5e9f0),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xffd8dee9),
      appBarTheme: const AppBarTheme(
        color: Color(0xff4c566a),
        iconTheme: IconThemeData(
          color: Color(0xffd8dee9),
        ),
      ),
      textTheme: ThemeData.light().textTheme,
      cardColor: const Color(0xffe5e9f0),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xffd8dee9),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: const Color(0xffd8dee9),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xff4c566a),
        secondary: const Color(0xff2e3440),
        brightness: Brightness.dark,
        background: const Color(0xff434c5e),
      ),
      scaffoldBackgroundColor: const Color(0xff434c5e),
      appBarTheme: const AppBarTheme(
        color: Color(0xff2e3440),
        foregroundColor: Color(0xffd8dee9),
        iconTheme: IconThemeData(
          color: Color(0xffd8dee9),
        ),
      ),
      textTheme: ThemeData.dark().textTheme,
      cardColor: const Color(0xff2e3440),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xff3b4252),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: const Color(0xff4c566a),
        ),
      ),
    );
  }
}
