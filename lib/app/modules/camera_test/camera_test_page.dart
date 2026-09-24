import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

import 'camera_test_controller.dart';

/// Camera Test Page - Toàn diện kiểm tra tất cả camera trên thiết bị (Tự động)
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
        ),
        body: Stack(
          children: [
            // ==================== KHUNG HÌNH XEM TRỰC TIẾP TỪ CAMERA ====================
            if (isReady && controller.controller.value != null)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width:
                        controller.controller.value!.value.previewSize!.height,
                    height:
                        controller.controller.value!.value.previewSize!.width,
                    child: CameraPreview(controller.controller.value!),
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
                      controller.cameraError.value ??
                          LocaleKeys.camera_test_camera_unavailable.trans(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Lớp đếm ngược đè lên preview — số to giữa màn hình để nhìn
            // thấy ngay cả khi đang cầm máy xa tầm mắt. Đặt SAU chuỗi
            // if/else của preview nên nó là một phần tử riêng của Stack,
            // nổi lên trên mọi trạng thái.
            if (controller.captureCountdown.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: _CaptureCountdown(
                      seconds: controller.captureCountdown.value,
                    ),
                  ),
                ),
              ),

            // ==================== CÁC TAB CHỌN CAMERA PHÍA TRÊN ====================
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
                            final result = controller.cameraResults[idx];
                            final isTested = result != null;
                            final passed = result == true;

                            return Padding(
                              padding: EdgeInsets.only(right: 8.0.w),
                              child: Chip(
                                avatar: Icon(
                                  isTested
                                      ? (passed
                                          ? Icons.check_circle
                                          : Icons.cancel)
                                      : (isCamFront
                                          ? Icons.camera_front
                                          : Icons.camera_rear),
                                  size: 16.r,
                                  color:
                                      isTested
                                          ? (passed
                                              ? AppColors.pass
                                              : AppColors.error)
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
                                backgroundColor: AppColors.neutralGrey900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : (isTested
                                                ? (passed
                                                    ? AppColors.pass
                                                    : AppColors.error)
                                                : Colors.transparent),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                    SizedBox(height: 8.h),

                    // Huy hiệu hướng dẫn thao tác tự động
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
                              controller.captureCountdown.value > 0
                                  ? LocaleKeys.camera_test_countdown_hint
                                      .trans()
                                  : (controller.isAutoCapturing.value
                                      ? LocaleKeys.camera_test_auto_capturing
                                          .trans()
                                      : (isFront
                                          ? 'Đang kiểm tra Camera trước'
                                          : 'Đang kiểm tra Camera sau (${currentCam?.name ?? ""})')),
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

            // ==================== HÌNH THU NHỎ ẢNH VỪA CHỤP ====================
            if (controller.capturedImagePath.value != null)
              Positioned(
                bottom: 40.h,
                left: 20.w,
                child: Container(
                  width: 70.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color:
                          controller.cameraResults[currentIdx] == true
                              ? AppColors.pass
                              : AppColors.error,
                      width: 2,
                    ),
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
                          controller.cameraResults[currentIdx] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              controller.cameraResults[currentIdx] == true
                                  ? AppColors.pass
                                  : AppColors.error,
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (controller.cameraResults[currentIdx] == false &&
                controller.capturedImagePath.value != null)
              Positioned(
                bottom: 40.h,
                left: 100.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    LocaleKeys.camera_test_black_frame_detected.trans(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Số đếm ngược to đè giữa preview trước khi tự chụp.
class _CaptureCountdown extends StatelessWidget {
  const _CaptureCountdown({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AnimatedSwitcher + ValueKey theo số giây: mỗi lần đổi số là một
        // nhịp phóng to - mờ dần, đủ để mắt bắt được nhịp đếm ngay cả khi
        // đang nhìn lệch màn hình.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder:
              (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 1.35, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
          child: Container(
            key: ValueKey<int>(seconds),
            width: 96.r,
            height: 96.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.black54,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Text(
              '$seconds',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.black54,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            LocaleKeys.camera_test_countdown_seconds.trans(
              namedArgs: {'seconds': '$seconds'},
            ),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
