import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/global_widgets/immersive_mode.dart';

import 'screen_defect_detection_controller.dart';

/// Tự động phát hiện lỗi màn hình: sốc, chảy mực, burn-in, dead pixel
/// (UI thuần — toàn bộ nghiệp vụ sống trong [ScreenDefectDetectionController]).
class ScreenDefectDetectionPage
    extends GetView<ScreenDefectDetectionController> {
  const ScreenDefectDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImmersiveMode(child: _ScreenDefectDetectionView());
  }
}

class _ScreenDefectDetectionView extends StatefulWidget {
  const _ScreenDefectDetectionView();

  @override
  State<_ScreenDefectDetectionView> createState() =>
      _ScreenDefectDetectionViewState();
}

class _ScreenDefectDetectionViewState
    extends State<_ScreenDefectDetectionView> {
  late final ScreenDefectDetectionController controller =
      Get.find<ScreenDefectDetectionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final patterns = controller.patterns;
      final step = controller.currentStep.value;
      final pattern = patterns[step];
      final progress = (step + 1) / patterns.length;

      return Scaffold(
        backgroundColor: pattern.color,
        body: Stack(
          children: [
            // Full screen color
            Positioned.fill(child: Container(color: pattern.color)),

            // Top info bar (semi-transparent)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.all(16.r),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.black87,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '${step + 1}/${patterns.length}',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Pattern name
                      Text(
                        pattern.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        pattern.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Instructions
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.warningDarkSurface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.warning, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: AppColors.white,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                LocaleKeys
                                    .screen_defect_detection_observe_instruction
                                    .trans(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      // Report defect button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.reportDefect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fail,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: const Icon(Icons.report_problem),
                          label: Text(
                            LocaleKeys.screen_defect_detection_report_defect
                                .trans(),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Skip button
                      ElevatedButton(
                        onPressed: controller.skipToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.screen_defect_detection_skip.trans(),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Defect indicator
            if (controller.userConfirmedDefect.value)
              Positioned(
                top: 100.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.fail,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.white,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        LocaleKeys.screen_defect_detection_defect_recorded.trans(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
