import 'package:flutter/material.dart';

class CustomTheme {
  static var currentTheme = lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.green,
        secondary: Colors.greenAccent,
        brightness: Brightness.light,
        background: Colors.white70,
      ),
      textTheme: ThemeData.light().textTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.blueGrey,
        secondary: Colors.tealAccent,
        brightness: Brightness.dark,
        background: Colors.black12,
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.blueGrey,
        iconTheme: IconThemeData(
          color: Colors.white70,
        ),
      ),
      textTheme: ThemeData.dark().textTheme,
    );
  }
}
