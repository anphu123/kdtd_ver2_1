import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Thẻ nền chuẩn: viền hairline + bo 16, có 3 độ nâng bề mặt để phân tầng
/// thay vì thẻ trắng viền xám đồng loạt.
enum PviSurfaceLevel {
  /// Nền phụ, chìm hơn trang (vùng thông tin phụ)
  low,

  /// Thẻ trắng thông thường
  base,

  /// Nhấn mạnh: viền navy đậm hơn (thẻ đang chạy / kết quả chính)
  high,
}

class PviSurfaceCard extends StatelessWidget {
  const PviSurfaceCard({
    super.key,
    required this.child,
    this.level = PviSurfaceLevel.base,
    this.padding,
    this.accent,
  });

  final Widget child;
  final PviSurfaceLevel level;
  final EdgeInsetsGeometry? padding;

  /// Màu viền ép riêng (vd amber khi đang chạy, đỏ khi lỗi)
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    switch (level) {
      case PviSurfaceLevel.low:
        bg = AppColors.surfaceSecondary;
        border = AppColors.borderSubtle;
      case PviSurfaceLevel.base:
        bg = AppColors.surface;
        border = AppColors.border;
      case PviSurfaceLevel.high:
        bg = AppColors.surface;
        border = AppColors.pviNavyBorder;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: accent ?? border,
          width: accent != null ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}
