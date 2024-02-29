import 'package:flutter/material.dart';

class ThemeController {
  ThemeController();

  static ThemeData mainTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        background: Color.fromARGB(255, 95, 77, 22),
        onBackground: Color(0xffffffff),
        primary: Color(0xffffbf00),
        onPrimary: Color(0xff000000),
        secondary: Color(0xff5581AD),
        onSecondary: Color(0xff000000),
        tertiary: Color(0xff80abff),
        onTertiary: Color(0xff000000),
        error: Color(0xffDE716D),
        onError: Color(0xff000000),
        surface: Color(0xff151515),
        onSurface: Color(0xffffffff),
        shadow: Color(0x55DE716D),
      ),
    );
  }
}
