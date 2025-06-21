import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();
  
  // Jus Mundi Brand Colors
  static const Color primaryGreen = Color(0xFF678D7F); // Main green accent
  static const Color darkGreen = Color(0xFF689F38); // Darker green for hover states
  static const Color lightGreen = Color(0xFFE8F5E8); // Light green for backgrounds
  static const Color paleGreen = Color(0xFFF0F8F0); // Very pale green
  
    // Weakness and Cases colors
  static const Color weaknessRed = Color(0xFFC85A5A); // Darker green for hover states
  static const Color casesGrey = Color(0xFF7B8D91); // Light green for backgrounds

  // Neutral Colors
  static const Color textDark = Color(0xFF263238); // Dark text
  static const Color textMedium = Color(0xFF546E7A); // Medium gray text
  static const Color textLight = Color(0xFF90A4AE); // Light gray text
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Very light gray background
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Pure white
  static const Color backgroundDark = Color(0xFF37474F); // Dark background for dark theme
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF); // White cards/surfaces
  static const Color surfaceDark = Color(0xFF455A64); // Dark theme surfaces
  static const Color surfaceHover = Color(0xFFF5F5F5); // Hover state for surfaces
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0); // Light borders
  static const Color borderMedium = Color(0xFFBDBDBD); // Medium borders
  static const Color borderDark = Color(0xFF607D8B); // Dark theme borders
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Badge/Chip Colors
  static const Color badgeGreen = Color(0xFF7CB342);
  static const Color badgeGray = Color(0xFF9E9E9E);
  static const Color badgeBlue = Color(0xFF1976D2);
  
  // Gradient Colors
  static const List<Color> greenGradient = [
    Color(0xFF7CB342),
    Color(0xFF689F38),
  ];
  
  static const List<Color> neutralGradient = [
    Color(0xFFF5F5F5),
    Color(0xFFEEEEEE),
  ];
}