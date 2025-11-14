import 'package:flutter/material.dart';

class AppTheme {
  // Core brand colors (Black / White / Gold)
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0B0B0B);
  static const Color textOnDark = Color(0xFFEFEFEF);

  static ThemeData get themeData {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: gold,
      onPrimary: black,
      secondary: goldDark,
      onSecondary: white,
      error: Colors.redAccent,
      onError: white,
      background: black,
      onBackground: textOnDark,
      surface: const Color(0xFF121212),
      onSurface: textOnDark,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: gold,
      scaffoldBackgroundColor: black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: textOnDark,
        elevation: 2,
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: gold.withOpacity(0.9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: textOnDark.withOpacity(0.7)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textOnDark),
        bodyMedium: TextStyle(color: textOnDark),
        titleMedium: TextStyle(color: textOnDark, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF0F0F0F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1B1B1B),
        contentTextStyle: const TextStyle(color: textOnDark),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
