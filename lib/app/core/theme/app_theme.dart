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

      // Giao diện AppBar (Xanh Navy phẳng)
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.textOnDark,
      ),

      // Giao diện Thẻ Card (Trắng thuần, phẳng, viền màu đặc)
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Giao diện ô nhập liệu (Input Decoration)
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

      // Giao diện nút bấm nổi bật (Đỏ PVI phẳng)
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

      // Nút chính dạng Filled: bo 14, cao tối thiểu 52 (đủ vùng chạm cho
      // kỹ thuật viên đeo găng), chữ đậm; trạng thái vô hiệu là xám phẳng.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 52),
          backgroundColor: AppColors.pviRed,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.surfaceSubtle,
          disabledForegroundColor: AppColors.textDisabled,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Nút phụ dạng viền
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: AppColors.pviNavy,
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Segmented button (chọn 1 trong nhiều) — chọn = navy đặc
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.border),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? AppColors.pviNavy
                    : AppColors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? AppColors.textOnDark
                    : AppColors.textSecondary,
          ),
        ),
      ),

      // Thanh tiến trình: track xám nhạt, không có hiệu ứng "stop indicator"
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.pviNavy,
        linearTrackColor: AppColors.surfaceSubtle,
        circularTrackColor: AppColors.surfaceSubtle,
        linearMinHeight: 6,
      ),

      // Dialog / bottom sheet / snackbar cùng ngôn ngữ bo góc 20
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pviNavyDark,
        contentTextStyle: const TextStyle(
          color: AppColors.textOnDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Giao diện nút hành động nổi (FAB không độ nổi/shadow)
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

      // Giao diện đường phân cách
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
        color: AppColors.border,
      ),
    );
  }

  /// Giao diện tối Dark Theme (Bảng màu tối phẳng)
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

      // Giao diện AppBar tối
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.pviNavyDark,
        foregroundColor: AppColors.textOnDark,
      ),

      // Giao diện Thẻ Card tối
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.pviNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.pviNavyBorder, width: 1),
        ),
      ),

      // Giao diện ô nhập liệu tối
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pviNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.pviNavyBorder,
            width: 1,
          ),
        ),
      ),

      // Giao diện nút bấm nổi bật tối
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

      // Giao diện nút hành động nổi tối
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: AppColors.pviRed,
        foregroundColor: AppColors.textOnDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Giao diện đường phân cách tối
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
        color: AppColors.pviNavyBorder,
      ),
    );
  }
}
