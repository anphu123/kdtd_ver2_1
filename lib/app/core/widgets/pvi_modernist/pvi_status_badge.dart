import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

enum PviBadgeVariant {
  success,
  error,
  warning,
  info,
  neutral,
  pviRed,
  pviNavy,
}

/// Pill badge chuẩn PVI Assurance Modernist (100% Solid)
class PviStatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final PviBadgeVariant variant;
  final double? fontSize;

  const PviStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = PviBadgeVariant.success,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color contentColor;

    switch (variant) {
      case PviBadgeVariant.success:
        bgColor = AppColors.tradeInEmeraldLight;
        borderColor = AppColors.tradeInEmeraldBorder;
        contentColor = AppColors.tradeInEmerald;
        break;
      case PviBadgeVariant.error:
      case PviBadgeVariant.pviRed:
        bgColor = AppColors.pviRedSurface;
        borderColor = AppColors.pviRedBorder;
        contentColor = AppColors.pviRed;
        break;
      case PviBadgeVariant.warning:
        bgColor = AppColors.warningSurface;
        borderColor = AppColors.warningBorder;
        contentColor = AppColors.warningDark;
        break;
      case PviBadgeVariant.info:
        bgColor = AppColors.pviBlueSurface;
        borderColor = AppColors.pviBlueBorder;
        contentColor = AppColors.pviBlue;
        break;
      case PviBadgeVariant.pviNavy:
        bgColor = AppColors.pviNavySurface;
        borderColor = AppColors.pviNavyBorder;
        contentColor = AppColors.pviNavy;
        break;
      case PviBadgeVariant.neutral:
        bgColor = AppColors.tradeInSurfaceBg;
        borderColor = AppColors.border;
        contentColor = AppColors.textMuted;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: (fontSize ?? 10.5.sp) + 3.sp, color: contentColor),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: AppTextStyles.badge.copyWith(
              fontSize: fontSize ?? 10.5.sp,
              color: contentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
