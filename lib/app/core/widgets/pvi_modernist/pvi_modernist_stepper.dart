import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Segmented Stepper chuẩn PVI Assurance Modernist
/// Hiển thị tiến trình 3 bước cốt lõi:
/// 1. Cấp quyền  ->  2. Đối soát  ->  3. Kiểm định
class PviModernistStepper extends StatelessWidget {
  /// Bước hiện tại (1, 2, hoặc 3)
  final int currentStep;

  /// Danh sách các bước đã hoàn thành (ví dụ: [1] khi bước 1 đã xong)
  final Set<int> completedSteps;

  const PviModernistStepper({
    super.key,
    required this.currentStep,
    this.completedSteps = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.tradeInSurfaceBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStepPill(
                stepIndex: 1,
                label: 'Cấp quyền',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16.sp,
                color: AppColors.borderStrong,
              ),
            ),
            Expanded(
              child: _buildStepPill(
                stepIndex: 2,
                label: 'Đối soát',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16.sp,
                color: AppColors.borderStrong,
              ),
            ),
            Expanded(
              child: _buildStepPill(
                stepIndex: 3,
                label: 'Kiểm định',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill({
    required int stepIndex,
    required String label,
  }) {
    final isActive = currentStep == stepIndex;
    final isDone = completedSteps.contains(stepIndex);

    final Color bgColor;
    final Color borderColor;
    final Color circleColor;
    final Color textColor;

    if (isDone && !isActive) {
      // Đã xong ở bước trước
      bgColor = AppColors.tradeInEmeraldLight;
      borderColor = AppColors.tradeInEmeraldBorder;
      circleColor = AppColors.tradeInEmerald;
      textColor = AppColors.tradeInEmerald;
    } else if (isActive) {
      if (isDone) {
        bgColor = AppColors.tradeInEmeraldLight;
        borderColor = AppColors.tradeInEmeraldBorder;
        circleColor = AppColors.tradeInEmerald;
        textColor = AppColors.tradeInEmerald;
      } else {
        bgColor = AppColors.pviRedSurface;
        borderColor = AppColors.pviRedBorder;
        circleColor = AppColors.pviRed;
        textColor = AppColors.pviRed;
      }
    } else {
      // Đang chờ (chưa thực hiện)
      bgColor = AppColors.white;
      borderColor = AppColors.border;
      circleColor = AppColors.border;
      textColor = AppColors.textMuted;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isDone
                ? Icon(Icons.check, size: 10.sp, color: AppColors.white)
                : Text(
                    '$stepIndex',
                    style: AppTextStyles.badge.copyWith(
                      color: isActive ? AppColors.white : AppColors.textMuted,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.badge.copyWith(
                color: textColor,
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
