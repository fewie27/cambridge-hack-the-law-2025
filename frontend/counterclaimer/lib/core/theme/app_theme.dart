import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Font settings - using a more neutral font stack similar to Jus Mundi
  static final _baseTextTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.textDark,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.textDark,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: AppColors.textDark,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: AppColors.textDark,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: AppColors.textDark,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: AppColors.textDark,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: AppColors.textDark,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: AppColors.textDark,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textMedium,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMedium,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textMedium,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textMedium,
    ),
  );

  // Light theme - matching Jus Mundi design
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      secondary: AppColors.darkGreen,
      onSecondary: Colors.white,
      error: AppColors.errorRed,
      onError: Colors.white,
      background: AppColors.backgroundLight,
      onBackground: AppColors.textDark,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textDark,
      surfaceVariant: AppColors.backgroundLight,
      onSurfaceVariant: AppColors.textMedium,
      outline: AppColors.borderLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    // Card theme for the list items
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      color: AppColors.surfaceLight,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.borderLight,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: AppColors.textDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
      ),
    ),
    
    textTheme: _baseTextTheme,
    
    // Search field styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderMedium, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderMedium, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textLight,
        fontSize: 16,
      ),
    ),
    
    // Green "Add to Alerts" button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: const BorderSide(color: AppColors.borderMedium, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        foregroundColor: AppColors.textDark,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text buttons for filters
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: AppColors.textDark,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Dividers
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),
    
    // Chips for categories/tags
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.paleGreen,
      labelStyle: GoogleFonts.inter(
        color: AppColors.primaryGreen,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppColors.primaryGreen, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    
    // List tile theme for search results
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
      ),
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: AppColors.textMedium,
      size: 20,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      secondary: AppColors.darkGreen,
      onSecondary: Colors.white,
      error: AppColors.errorRed,
      onError: Colors.white,
      background: AppColors.backgroundDark,
      onBackground: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: Colors.white,
      surfaceVariant: AppColors.surfaceDark,
      onSurfaceVariant: AppColors.textLight,
      outline: AppColors.borderDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    
    textTheme: _baseTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textLight,
        fontSize: 16,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: const BorderSide(color: AppColors.borderDark, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 1,
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDark,
      labelStyle: GoogleFonts.inter(
        color: AppColors.primaryGreen,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppColors.primaryGreen, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      ),
    ),
    
    iconTheme: const IconThemeData(
      color: AppColors.textLight,
      size: 20,
    ),
  );
}