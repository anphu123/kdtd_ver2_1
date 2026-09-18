import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

import 'camera_test_controller.dart';

/// Camera Test Page - Toàn diện kiểm tra tất cả camera trên thiết bị
class CameraTestPage extends GetView<CameraTestController> {
  const CameraTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReady = controller.isReady;
      final currentCam = controller.currentCamera;
      final total = controller.totalCameras;
      final currentIdx = controller.currentCameraIndex.value;
      final isFront = currentCam?.lensDirection == CameraLensDirection.front;

      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => controller.finish(false),
          ),
          title: Text(
            total > 1
                ? 'Kiểm tra Camera (${currentIdx + 1}/$total)'
                : 'Kiểm tra Camera',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
          actions: [
            if (isReady && !isFront)
              IconButton(
                icon: Icon(
                  controller.isFlashOn.value
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color:
                      controller.isFlashOn.value
                          ? AppColors.warning
                          : AppColors.white70,
                ),
                tooltip: 'Kiểm tra Đèn Flash',
                onPressed: controller.testFlash,
              ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.pass),
              tooltip: 'Xác nhận Camera tốt',
              onPressed: controller.confirmCurrentCamera,
            ),
          ],
        ),
        body: Stack(
          children: [
            // ==================== LIVE CAMERA PREVIEW ====================
            if (isReady && controller.controller.value != null)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (details) {
                    controller.testFocus(details.localPosition);
                  },
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:
                          controller
                              .controller
                              .value!
                              .value
                              .previewSize!
                              .height,
                      height:
                          controller
                              .controller
                              .value!
                              .value
                              .previewSize!
                              .width,
                      child: CameraPreview(controller.controller.value!),
                    ),
                  ),
                ),
              )
            else if (controller.isInitializing.value)
              const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      size: 64.r,
                      color: AppColors.white54,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      LocaleKeys.camera_test_camera_unavailable.trans(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // ==================== TOP CAMERA SELECTOR TABS ====================
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (total > 1)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(total, (idx) {
                            final cam = controller.cameras[idx];
                            final isCamFront =
                                cam.lensDirection == CameraLensDirection.front;
                            final isSelected = idx == currentIdx;
                            final isTested =
                                controller.testedCameras.contains(idx);

                            return Padding(
                              padding: EdgeInsets.only(right: 8.0.w),
                              child: ChoiceChip(
                                avatar: Icon(
                                  isTested
                                      ? Icons.check_circle
                                      : (isCamFront
                                          ? Icons.camera_front
                                          : Icons.camera_rear),
                                  size: 16.r,
                                  color:
                                      isTested
                                          ? AppColors.pass
                                          : (isSelected
                                              ? AppColors.white
                                              : AppColors.white70),
                                ),
                                label: Text(
                                  'Cam ${idx + 1}: ${isCamFront ? "Trước" : "Sau"}',
                                  style: AppTextStyles.badge.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? AppColors.white
                                            : AppColors.white70,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.neutralGrey900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : (isTested
                                                ? AppColors.pass
                                                : Colors.transparent),
                                    width: 1.5,
                                  ),
                                ),
                                onSelected: (_) => controller.switchCamera(idx),
                              ),
                            );
                          }),
                        ),
                      ),

                    SizedBox(height: 8.h),

                    // Instruction badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutralGrey900,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFront ? Icons.face : Icons.camera,
                            size: 16.r,
                            color: AppColors.white70,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              isFront
                                  ? 'Đang kiểm tra Camera trước (Chụp thử để xác nhận)'
                                  : 'Đang kiểm tra Camera sau (${currentCam?.name ?? ""}) — Thử chạm để lấy nét',
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

            // ==================== CAPTURED PHOTO THUMBNAIL ====================
            if (controller.capturedImagePath.value != null)
              Positioned(
                bottom: 120.h,
                left: 20.w,
                child: Container(
                  width: 70.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.pass, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(controller.capturedImagePath.value!),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.pass,
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ==================== FLOATING CONTROLS ====================
            if (isReady)
              Positioned(
                bottom: 110.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút Focus
                    IconButton.filledTonal(
                      onPressed: controller.testFocus,
                      icon: Icon(Icons.center_focus_strong, size: 24.r),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black54,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.all(12.r),
                      ),
                      tooltip: 'Lấy nét',
                    ),

                    // Nút Chụp ảnh
                    GestureDetector(
                      onTap: controller.captureTest,
                      child: Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.white70,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 32.r,
                          color: AppColors.black,
                        ),
                      ),
                    ),

                    // Nút Chuyển camera (nếu có nhiều camera)
                    if (total > 1)
                      IconButton.filledTonal(
                        onPressed: controller.nextCamera,
                        icon: Icon(Icons.flip_camera_ios, size: 24.r),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.black54,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.all(12.r),
                        ),
                        tooltip: 'Đổi Camera',
                      )
                    else
                      SizedBox(width: 48.w),
                  ],
                ),
              ),
          ],
        ),
        // ==================== BOTTOM NAVIGATION BAR ====================
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.black87,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: controller.skipCamera,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white38),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(LocaleKeys.camera_test_skip.trans()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: controller.confirmCurrentCamera,
                    icon: Icon(Icons.check_circle_outline, size: 20.r),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pass,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    label: Text(
                      total > 1 &&
                              controller.testedCameras.length < total
                          ? 'Đạt cam này → Kế tiếp (${controller.testedCameras.length + 1}/$total)'
                          : 'Xác nhận Camera tốt (Đạt)',
                      style: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
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
}
