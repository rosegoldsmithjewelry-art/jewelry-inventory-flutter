import 'package:flutter/material.dart';

class AppTheme {
  // Core brand colors (Black / White / Gold)
  static const Color gold = Color(0xFFFFD700);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color accent = Color(0xFFB8860B); // darker gold
  static const Color textPrimary = black;

  static ThemeData get themeData {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: gold,
      primary: gold,
      secondary: accent,
      brightness: Brightness.light,
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      primaryColor: gold,
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        backgroundColor: gold,
        foregroundColor: textPrimary,
        elevation: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: textPrimary,
      ),
  // useMaterial3 is managed by the ThemeData constructors; avoid setting here to satisfy new lints.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color.fromARGB(230, 255, 215, 0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Color.fromARGB(204, 255, 215, 0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
