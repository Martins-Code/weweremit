import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF0B63F6);
  static const Color royalBlue = Color(0xFF1A4ED9);
  static const Color oceanTeal = Color(0xFF00A8E8);
  static const Color blushPurple = Color(0xFF7B5CFF);
  static const Color surface = Color(0xFFF5F7FB);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF0F1D3D);
  static const Color textSecondary = Color(0xFF5A6A90);
  static const Color success = Color(0xFF2FCC71);
  static const Color warning = Color(0xFFF3A712);
}

class Gradients {
  Gradients._();

  static const LinearGradient hero = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.oceanTeal, AppColors.blushPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient button = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.royalBlue, AppColors.blushPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccent = LinearGradient(
    colors: [Color(0xFFE8F1FF), Color(0xFFEAF7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.oceanTeal,
        brightness: Brightness.light,
        surface: AppColors.cardBackground,
        background: AppColors.surface,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.cardBackground,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              backgroundColor: const MaterialStatePropertyAll<Color>(
                Colors.transparent,
              ),
              shadowColor: const MaterialStatePropertyAll<Color>(
                Colors.black12,
              ),
              elevation: const MaterialStatePropertyAll<double>(4),
            ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E7FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD2DCF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: EdgeInsets.zero,
        color: AppColors.cardBackground,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      dividerTheme: base.dividerTheme.copyWith(
        thickness: 1,
        color: const Color(0xFFE6EBF5),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFE7F6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
