import 'package:flutter/material.dart';

class AppColors {
  // Background colors - Space theme dengan biru tua keunguan
  static const Color darkBluePurple = Color(0xFF0A0E27); // Primary background
  static const Color deepPurple = Color(0xFF1A1B3E);    // Secondary background
  static const Color darkPurple = Color(0xFF2D1B4E);    // Tertiary background

  // Text colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color silver = Color(0xFFE8E8E8);       // Silver/light gray
  static const Color lightGray = Color(0xFFA8A8A8);    // Light gray untuk secondary text

  // Accent colors
  static const Color brightBlue = Color(0xFF00D4FF);   // Bright blue cyan untuk tombol penting
  static const Color lightBlue = Color(0xFF4DB8E8);    // Light blue untuk hover states
  static const Color neonPurple = Color(0xFF9D4EDD);   // Neon purple untuk highlight

  // Status colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Border colors
  static const Color borderColor = Color(0xFF3D3D5C);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Color scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.brightBlue,
        onPrimary: AppColors.darkBluePurple,
        secondary: AppColors.neonPurple,
        onSecondary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        background: AppColors.darkBluePurple,
        onBackground: AppColors.white,
        surface: AppColors.deepPurple,
        onSurface: AppColors.white,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.darkBluePurple,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),

      // Text themes
      textTheme: TextTheme(
        // Display styles
        displayLarge: const TextStyle(
          color: AppColors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
        displayMedium: const TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        displaySmall: const TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),

        // Headline styles
        headlineMedium: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        headlineSmall: const TextStyle(
          color: AppColors.silver,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),

        // Title styles
        titleLarge: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        titleMedium: const TextStyle(
          color: AppColors.silver,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        titleSmall: const TextStyle(
          color: AppColors.lightGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),

        // Body styles
        bodyLarge: const TextStyle(
          color: AppColors.silver,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
        bodyMedium: const TextStyle(
          color: AppColors.silver,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
        bodySmall: const TextStyle(
          color: AppColors.lightGray,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),

        // Label styles
        labelLarge: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        labelMedium: const TextStyle(
          color: AppColors.silver,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        labelSmall: const TextStyle(
          color: AppColors.lightGray,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brightBlue,
          foregroundColor: AppColors.darkBluePurple,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Text button themes
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brightBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Outlined button themes
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brightBlue,
          side: const BorderSide(color: AppColors.brightBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepPurple,
        hintStyle: const TextStyle(
          color: AppColors.lightGray,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        labelStyle: const TextStyle(
          color: AppColors.silver,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brightBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.deepPurple,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.deepPurple,
        selectedColor: AppColors.brightBlue,
        labelStyle: const TextStyle(
          color: AppColors.silver,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: AppColors.borderColor),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightBlue,
        foregroundColor: AppColors.darkBluePurple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.deepPurple,
        indicatorColor: AppColors.brightBlue,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brightBlue,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
        space: 1,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.deepPurple,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.silver,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.deepPurple,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
    );
  }
}
