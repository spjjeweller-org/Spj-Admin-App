import 'package:flutter/material.dart';

class ThemeClass {
  static importTheme() {
    return ThemeData(
      colorScheme: const ColorScheme(
        primary: Colors.black54,
        secondary: Color(0xFFD243E5),
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        error: Color(0xFFB00020),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        onBackground: Color(0xFFFFFFFF),
        onError: Color(0xFFFFFFFF),
        tertiary: Color.fromARGB(255, 54, 54, 54),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
