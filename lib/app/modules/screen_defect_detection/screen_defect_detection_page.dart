import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/global_widgets/immersive_mode.dart';

import 'screen_defect_detection_controller.dart';

/// Tự động phát hiện lỗi màn hình: sốc, chảy mực, burn-in, dead pixel
/// (UI thuần — toàn bộ nghiệp vụ sống trong [ScreenDefectDetectionController]).
class ScreenDefectDetectionPage extends GetView<ScreenDefectDetectionController> {
  const ScreenDefectDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImmersiveMode(child: _ScreenDefectDetectionView());
  }
}

class _ScreenDefectDetectionView extends StatefulWidget {
  const _ScreenDefectDetectionView();

  @override
  State<_ScreenDefectDetectionView> createState() => _ScreenDefectDetectionViewState();
}

class _ScreenDefectDetectionViewState extends State<_ScreenDefectDetectionView> {
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
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(width: 12),
                          Text(
                            '${step + 1}/${patterns.length}',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Pattern name
                      Text(
                        pattern.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pattern.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.orange, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, color: AppColors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Quan sát kỹ màn hình. Nếu thấy vết lạ, nhấn "Báo lỗi"',
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
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Report defect button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.reportDefect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fail,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.report_problem),
                          label: Text(
                            'Báo lỗi',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Skip button
                      ElevatedButton(
                        onPressed: controller.skipToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Bỏ qua',
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
                top: 100,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fail,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fail.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: AppColors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Đã ghi nhận lỗi',
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
