// ==============================================================================
// DOSYA ADI: lib/core/theme/app_theme.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Uygulamanın görsel tasarım sistemini ve tema paletini (Aydınlık / Karanlık) tanımlar.
// - Aydınlık Mod: Doğa Yeşili (#2E7D32) ve organik sağlık tonlarını barındırır.
// - Karanlık Mod: Okyanus Gece Mavisi (#0096C7 / #0A1118) ile gözü yormayan premium kontrast sağlar.
// - Kartlar, butonlar, açılır menüler, metin alanları ve gezinme çubuğunun renk ve tipografi kurallarını belirler.
// - Tüm ekranların görsel tutarlılığını doğrudan etkiler.
// ==============================================================================

import 'package:flutter/material.dart';

/// Uygulamanın Aydınlık ve Karanlık mod ThemeData tanımlarını içeren tema yöneticisi.
class AppTheme {
  // Light Mode Colors (Doğa Yeşili)
  static const Color lightPrimary = Color(0xFF2E7D32);
  static const Color lightPrimaryContainer = Color(0xFFA5D6A7);
  static const Color lightSecondary = Color(0xFF43A047);
  static const Color lightButton = Color(0xFF81C784);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7FAF7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1B2E1B);
  static const Color lightTextSecondary = Color(0xFF5A6E5A);
  static const Color lightBorder = Color(0xFFE0E8E0);

  // Dark Mode Colors (Okyanus Mavisi)
  static const Color darkPrimary = Color(0xFF0096C7);
  static const Color darkPrimaryContainer = Color(0xFF023E8A);
  static const Color darkSecondary = Color(0xFF48CAE4);
  static const Color darkButton = Color(0xFF0077B6);
  static const Color darkBackground = Color(0xFF0A1118);
  static const Color darkSurface = Color(0xFF131D28);
  static const Color darkCard = Color(0xFF192534);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B9EB3);
  static const Color darkBorder = Color(0xFF223447);

  // Status Colors
  static const Color statusSuccess = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFF57C00);
  static const Color statusDanger = Color(0xFFD32F2F);
  static const Color statusInfo = Color(0xFF0288D1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        primaryContainer: lightPrimaryContainer,
        secondary: lightSecondary,
        surface: lightSurface,
        error: statusDanger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: lightPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary),
        hintStyle: TextStyle(color: lightTextSecondary.withOpacity(0.7)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightBackground,
        indicatorColor: lightPrimary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: lightPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: lightTextSecondary,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: lightPrimary);
          }
          return const IconThemeData(color: lightTextSecondary);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryContainer,
        secondary: darkSecondary,
        surface: darkSurface,
        error: statusDanger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.7)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: darkPrimary.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: darkTextSecondary,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: darkPrimary);
          }
          return const IconThemeData(color: darkTextSecondary);
        }),
      ),
    );
  }
}
