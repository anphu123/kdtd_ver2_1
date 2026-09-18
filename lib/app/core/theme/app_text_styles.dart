import 'package:flutter/material.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';

/// AppTextStyles - Hệ thống Typography chuẩn hóa của dự án
/// Sử dụng kèm ScreenUtil (.sp) và có thể mở rộng bằng `.copyWith(...)`
class AppTextStyles {
  AppTextStyles._();

  // ===========================================================================
  // 1. APP BAR & HERO TITLES (Tiêu đề đỉnh trang)
  // ===========================================================================

  /// Tiêu đề thanh AppBar chính (16sp, w800)
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );

  /// Tiêu đề banner hero / header chính (18sp, w800)
  static const TextStyle heroTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
  );

  // ===========================================================================
  // 2. SECTION & CARD TITLES (Tiêu đề khối & thẻ)
  // ===========================================================================

  /// Tiêu đề khối chức năng lớn (18sp, bold)
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Tiêu đề thẻ chức năng / Card Title (16sp, bold)
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  /// Tiêu đề cấp vừa (16sp, semi-bold)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  /// Tiêu đề cấp nhỏ (14sp, semi-bold)
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ===========================================================================
  // 3. BODY & CONTENT (Nội dung văn bản chính)
  // ===========================================================================

  /// Văn bản body lớn (16sp, regular)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  /// Văn bản body tiêu chuẩn (14sp, regular)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  /// Văn bản body nhỏ (12sp, regular)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // ===========================================================================
  // 4. BADGES, TAGS & LABELS (Nhãn phân loại & trạng thái)
  // ===========================================================================

  /// Nhãn badge tiêu chuẩn (11sp, bold)
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  /// Nhãn badge nhỏ (10sp, bold)
  static const TextStyle badgeSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  /// Nhãn voucher ưu đãi (12sp, bold)
  static const TextStyle voucherBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ===========================================================================
  // 5. BUTTONS & ACTIONS (Nút bấm tương tác)
  // ===========================================================================

  /// Nút bấm tiêu chuẩn (14sp, semi-bold)
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
  );

  /// Nút bấm lớn / CTA (15sp, bold)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // ===========================================================================
  // 6. METRICS & VALUES (Số liệu hiển thị)
  // ===========================================================================

  /// Giá trị số thống kê lớn (28sp, bold)
  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  /// Nhãn mô tả số liệu thống kê (13sp, medium)
  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// Hiển thị giá trị định giá lớn (26sp, bold)
  static const TextStyle priceDisplay = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  /// Hiển thị giá trị định giá nhỏ (16sp, bold)
  static const TextStyle priceSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // ===========================================================================
  // 7. CAPTIONS & OVERLINES (Chú thích & thông tin phụ)
  // ===========================================================================

  /// Chú thích tiêu chuẩn (12sp, regular)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  /// Chú thích nhỏ (10sp, medium)
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  // ===========================================================================
  // 8. DISPLAY & HEADLINES (Tiêu đề hiển thị lớn)
  // ===========================================================================

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
}
