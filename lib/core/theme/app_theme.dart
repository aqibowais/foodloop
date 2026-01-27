import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // Global gradient decoration for full-screen backgrounds
  static BoxDecoration get gradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.gradientStart,
        AppColors.gradientMiddle,
        AppColors.gradientEnd,
      ],
      stops: [0.0, 0.4, 1.0],
    ),
  );

  /// Dark theme inspired by FoodLoop UI
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.accentGreen,
        secondary: AppColors.accentGreenSoft,
        surface: AppColors.cardDark,
        background: AppColors.black,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.pureWhite,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1(color: AppColors.pureWhite),
        headlineMedium: AppTypography.h3(color: AppColors.pureWhite),
        bodyLarge: AppTypography.body(color: AppColors.pureWhite),
        bodyMedium: AppTypography.bodySmall(color: AppColors.grey),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.pureWhite),
      ),
      cardColor: AppColors.cardDark,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTypography.caption(color: AppColors.accentGreen),
        unselectedLabelStyle: AppTypography.caption(color: AppColors.grey),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
      ),
    );
  }
}
