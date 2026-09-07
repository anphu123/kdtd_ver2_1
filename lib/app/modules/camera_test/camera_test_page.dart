import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'camera_test_controller.dart';
import 'widgets/step_indicator.dart';

/// Camera Test - Comprehensive
/// - Test camera trước/sau
/// - Test chụp ảnh
/// - Test chống rung (OIS detection)
/// - Test focus
/// - Test flash
///
/// UI thuần — toàn bộ nghiệp vụ sống trong [CameraTestController]
/// (gắn qua `CameraTestBinding`, nhận `cameras` qua `Get.arguments`).
class CameraTestPage extends GetView<CameraTestController> {
  const CameraTestPage({super.key});

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Bước 1: Camera Trước';
      case 1:
        return 'Bước 2: Camera Sau';
      case 2:
        return 'Bước 3: Chụp Ảnh';
      case 3:
        return 'Bước 4: Test Focus';
      case 4:
        return 'Bước 5: Test Flash';
      default:
        return 'Hoàn thành';
    }
  }

  String _stepInstruction(int step) {
    switch (step) {
      case 0:
        return 'Kiểm tra camera trước có hoạt động không';
      case 1:
        return 'Kiểm tra camera sau có hoạt động không';
      case 2:
        return 'Nhấn nút chụp để test chức năng chụp ảnh';
      case 3:
        return 'Nhấn để test tự động lấy nét (autofocus)';
      case 4:
        return 'Nhấn để test đèn flash';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReady = controller.isReady;
      final step = controller.currentStep.value;

      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black87,
          title: Text(_stepTitle(step)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.finish(false),
          ),
        ),
        body: Stack(
          children: [
            // Camera Preview
            if (isReady)
              Positioned.fill(
                child: controller.capturedImagePath.value != null && step == 2
                    ? Image.file(File(controller.capturedImagePath.value!), fit: BoxFit.cover)
                    : FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.controller.value!.value.previewSize!.height,
                          height: controller.controller.value!.value.previewSize!.width,
                          child: CameraPreview(controller.controller.value!),
                        ),
                      ),
              )
            else if (controller.isInitializing.value)
              const Center(child: CircularProgressIndicator(color: AppColors.white))
            else
              Center(
                child: Text(
                  'Camera không khả dụng',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
              ),

            // Step indicator
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StepIndicator(
                            number: 1,
                            isActive: step == 0,
                            isCompleted: controller.frontCameraTested.value,
                          ),
                          StepIndicator(
                            number: 2,
                            isActive: step == 1,
                            isCompleted: controller.backCameraTested.value,
                          ),
                          StepIndicator(
                            number: 3,
                            isActive: step == 2,
                            isCompleted: controller.captureTested.value,
                          ),
                          StepIndicator(
                            number: 4,
                            isActive: step == 3,
                            isCompleted: controller.focusTested.value,
                          ),
                          StepIndicator(
                            number: 5,
                            isActive: step == 4,
                            isCompleted: controller.flashTested.value,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stepInstruction(step),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                      ),

                      // OIS/Stabilization info
                      if (step >= 1) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: controller.hasStabilization.value
                                ? AppColors.pass.withValues(alpha: 0.3)
                                : AppColors.info.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.hasStabilization.value ? AppColors.pass : AppColors.info,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.hasStabilization.value
                                    ? Icons.check_circle
                                    : Icons.videocam,
                                color: controller.hasStabilization.value ? AppColors.pass : AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.hasStabilization.value
                                      ? '✓ Phát hiện chống rung (OIS/EIS)'
                                      : 'Đang kiểm tra chống rung...',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color:
                                        controller.hasStabilization.value ? AppColors.pass : AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Camera warning
                      if (controller.cameraWarning.value != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: controller.isOriginal.value
                                ? AppColors.pass.withValues(alpha: 0.3)
                                : AppColors.warning.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.isOriginal.value ? AppColors.pass : AppColors.warning,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.isOriginal.value ? Icons.check_circle : Icons.warning,
                                color: controller.isOriginal.value ? AppColors.pass : AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.cameraWarning.value!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: controller.isOriginal.value ? AppColors.pass : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Camera count
                      const SizedBox(height: 8),
                      Text(
                        'Tổng: ${controller.totalCameras.value} camera',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action button for current step
            if (isReady)
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(child: _buildActionButton(step)),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.black87,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.skipStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Bỏ qua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.nextStep,
                    style: FilledButton.styleFrom(
                      backgroundColor: isReady ? AppColors.pass : AppColors.pass.withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      step < 2 ? (isReady ? 'Tiếp tục' : 'Tiếp tục (Thủ công)') : 'Hoàn thành',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(int step) {
    IconData icon;
    VoidCallback? onPressed;

    switch (step) {
      case 2:
        icon = Icons.camera_alt;
        onPressed = controller.captureTest;
        break;
      case 3:
        icon = Icons.center_focus_strong;
        onPressed = controller.testFocus;
        break;
      case 4:
        icon = Icons.flash_on;
        onPressed = controller.testFlash;
        break;
      default:
        return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: AppColors.black),
      ),
    );
  }
}
