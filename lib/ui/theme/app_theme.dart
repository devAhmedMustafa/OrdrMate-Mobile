import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF); // Purple
  static const Color secondaryColor = Color(0xFFFFB74D); // Light Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray Background
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color errorColor = Color(0xFFCF6679);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121); // Dark Gray
  static const Color textSecondaryColor = Color(0xFF757575); // Medium Gray
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border Radius
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  
  // Shadows
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryColor),
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.all(spacingM),
      ),
    );
  }
} 