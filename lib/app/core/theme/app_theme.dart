import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTheme - Cấu hình Flutter Theme thống nhất toàn ứng dụng
/// Phong cách Flat Solid PVI: 100% màu thuần, không bóng mờ (elevation: 0)
class AppTheme {
  AppTheme._();

  /// Light Theme (Chế độ sáng chủ đạo theo nhận diện thương hiệu PVI)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pviNavy,
        primary: AppColors.pviNavy,
        secondary: AppColors.pviRed,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),

      // App Bar Theme (Flat Navy)
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.textOnDark,
      ),

      // Card Theme (Pure White, Flat, Solid Border)
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.pviNavy, width: 1.5),
        ),
      ),

      // Elevated Button Theme (Solid Flat PVI Red)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.pviRed,
          foregroundColor: AppColors.textOnDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Floating Action Button Theme (Zero elevation)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: AppColors.pviRed,
        foregroundColor: AppColors.textOnDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
        color: AppColors.border,
      ),
    );
  }

  /// Dark Theme (Flat Dark Palette)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.pviNavyDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pviNavy,
        primary: AppColors.pviNavy,
        secondary: AppColors.pviRed,
        brightness: Brightness.dark,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.pviNavyDark,
        foregroundColor: AppColors.textOnDark,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.pviNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.pviNavyBorder, width: 1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pviNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.pviNavyBorder, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.pviRed,
          foregroundColor: AppColors.textOnDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: AppColors.pviRed,
        foregroundColor: AppColors.textOnDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
        color: AppColors.pviNavyBorder,
      ),
    );
  }
}
