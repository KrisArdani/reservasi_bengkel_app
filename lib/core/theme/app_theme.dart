import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color backgroundMatteBlack = Color(0xFF121212);
  static const Color primaryBlue = Color(0xFF1D4ED8); // Royal Blue instead of Crimson Red
  static const Color cardDarkCharcoal = Color(0xFF1E1E1E);
  static const Color textSlateWhite = Color(0xFFF8FAFC);
  static const Color textSlateGrayMuted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    final TextTheme baseTextTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundMatteBlack,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: cardDarkCharcoal,
        onPrimary: textSlateWhite,
        onSurface: textSlateWhite,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: textSlateWhite),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: textSlateWhite),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: textSlateWhite),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: textSlateWhite),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: textSlateWhite),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: textSlateWhite),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: textSlateWhite),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: textSlateWhite),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: textSlateWhite),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textSlateWhite),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSlateWhite),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSlateGrayMuted),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: textSlateWhite),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: textSlateGrayMuted),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: textSlateGrayMuted),
      ),
      cardTheme: const CardThemeData(
        color: cardDarkCharcoal,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textSlateWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkCharcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: textSlateGrayMuted),
        hintStyle: const TextStyle(color: textSlateGrayMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundMatteBlack,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textSlateWhite),
        titleTextStyle: TextStyle(
          color: textSlateWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
