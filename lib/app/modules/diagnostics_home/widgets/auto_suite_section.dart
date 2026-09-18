/// ============================================================
/// AutoSuiteSection - Phần Khởi Động Test Tự Động
/// ============================================================
///
/// Widget hiển thị button để bắt đầu các test tự động.
/// Bao gồm:
/// - Tiêu đề và mô tả
/// - Button bắt đầu/đang chạy
/// ============================================================
library;

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

class AutoSuiteSection extends StatelessWidget {
  const AutoSuiteSection({
    super.key,
    required this.onStartAuto,
    required this.isRunning,
  });

  /// Callback khi nhấn nút bắt đầu
  final VoidCallback? onStartAuto;

  /// Đang chạy test hay không
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppColors.pviRedLighter,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.verified_rounded,
                  size: 20.r,
                  color: AppColors.tradeInBlue,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.diagnostics_home_auto_suite_title.trans(),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.tradeInNavy,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      LocaleKeys.diagnostics_home_auto_suite_subtitle.trans(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralGreyDark,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Big 1-Touch Button
          Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: isRunning ? AppColors.neutralGreyLighter : AppColors.pviRed,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: isRunning ? null : onStartAuto,
                borderRadius: BorderRadius.circular(12.r),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.hourglass_empty_rounded
                            : Icons.bolt_rounded,
                        color:
                            isRunning
                                ? AppColors.neutralGreyDark
                                : AppColors.white,
                        size: 22.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isRunning
                            ? LocaleKeys.diagnostics_home_auto_suite_running
                                .trans()
                            : LocaleKeys.diagnostics_home_auto_suite_start.trans(),
                        style: AppTextStyles.button.copyWith(
                          color: isRunning
                              ? AppColors.neutralGreyDark
                              : AppColors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Privacy note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13.r,
                color: AppColors.neutralGrey,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  LocaleKeys.diagnostics_home_auto_suite_privacy_note.trans(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
