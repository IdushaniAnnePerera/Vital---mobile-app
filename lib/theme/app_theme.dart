import 'package:flutter/material.dart';

/// Vital design system.
///
/// Direction: a calm, clinical-but-warm palette. Deep teal as the anchor
/// (health, trust, water), a soft coral accent for energy/action, on a
/// near-white "paper" background. Rounded, generous spacing — nothing
/// shouts. The five health domains each get a signature hue so the app
/// reads as one system with five rooms.
class AppColors {
  static const paper = Color(0xFFF7F8F7);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF14302E);
  static const inkSoft = Color(0xFF5C6B69);
  static const teal = Color(0xFF0E7C7B);
  static const tealDark = Color(0xFF0A5E5D);
  static const coral = Color(0xFFFF6B5B);
  static const line = Color(0xFFE4E8E6);

  // Domain accents
  static const steps = Color(0xFF0E7C7B); // teal
  static const workout = Color(0xFFF2682C); // orange
  static const meals = Color(0xFF6A8E3C); // olive green
  static const meds = Color(0xFF7A5CC4); // violet
  static const sleep = Color(0xFF3C5C9E); // indigo
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.teal,
        secondary: AppColors.coral,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ).copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0x1F0E7C7B), // teal @ 12%
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        height: 68,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
