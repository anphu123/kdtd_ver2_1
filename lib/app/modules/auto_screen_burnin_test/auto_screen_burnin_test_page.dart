import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/global_widgets/immersive_mode.dart';

import 'auto_screen_burnin_test_controller.dart';

/// Auto Screen Burn-In Test - For Tier 5 (old/low-end devices) (UI thuần)
/// Tự động chạy qua các màu để phát hiện sọc ám.
///
/// Toàn bộ nghiệp vụ sống trong [AutoScreenBurnInTestController]; trang này
/// chỉ đọc `.obs` field qua `Obx` và gọi lại các method của controller khi
/// người dùng tương tác.
class AutoScreenBurnInTestPage extends GetView<AutoScreenBurnInTestController> {
  const AutoScreenBurnInTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImmersiveMode(child: _AutoScreenBurnInTestView());
  }
}

class _AutoScreenBurnInTestView extends StatefulWidget {
  const _AutoScreenBurnInTestView();

  @override
  State<_AutoScreenBurnInTestView> createState() =>
      _AutoScreenBurnInTestViewState();
}

class _AutoScreenBurnInTestViewState extends State<_AutoScreenBurnInTestView> {
  late final AutoScreenBurnInTestController controller =
      Get.find<AutoScreenBurnInTestController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.started.value) {
        // Màn hình countdown
        return Scaffold(
          backgroundColor: AppColors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.screen_search_desktop,
                  size: 80.r,
                  color: AppColors.white,
                ),
                SizedBox(height: 32.h),
                Text(
                  LocaleKeys.auto_screen_burnin_test_title.trans(),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  LocaleKeys.auto_screen_burnin_test_instruction_center.trans(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white70,
                  ),
                ),
                SizedBox(height: 48.h),
                Text(
                  '${controller.countdown.value}',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.infoMedium,
                    fontSize: 72.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.auto_screen_burnin_test_starting_soon.trans(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final current =
          kAutoScreenBurnInTestColors[controller.currentIndex.value];
      final isDark = current.color.computeLuminance() < 0.5;
      final textColor = isDark ? AppColors.white : AppColors.black;
      final textMutedColor = isDark ? AppColors.white70 : AppColors.textMuted;
      final textHintColor = isDark ? AppColors.white54 : AppColors.neutralGreyDark;
      final buttonColor = isDark ? AppColors.white24 : AppColors.black12;
      final isRunning = controller.isRunning.value;

      return Scaffold(
        backgroundColor: current.color,
        body: SafeArea(
          child: Stack(
            children: [
              // Toàn màn hình một màu
              Container(color: current.color),

              // Info nhỏ ở góc trên
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.auto_screen_burnin_test_progress_label.trans(
                                namedArgs: {
                                  'current':
                                      '${controller.currentIndex.value + 1}',
                                  'total':
                                      '${kAutoScreenBurnInTestColors.length}',
                                  'name': current.name,
                                },
                              ),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              current.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: textMutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed:
                            isRunning ? controller.pause : controller.resume,
                        icon: Icon(
                          isRunning ? Icons.pause : Icons.play_arrow,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress bar
              Positioned(
                top: 80.h,
                left: 16.w,
                right: 16.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value:
                        (controller.currentIndex.value + 1) /
                        kAutoScreenBurnInTestColors.length,
                    minHeight: 8.h,
                    backgroundColor: buttonColor,
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? AppColors.infoMedium : AppColors.infoDark,
                    ),
                  ),
                ),
              ),

              // Hướng dẫn nhỏ ở giữa
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    LocaleKeys.auto_screen_burnin_test_auto_switching.trans(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textHintColor,
                    ),
                  ),
                ),
              ),

              // Emergency buttons ở dưới
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        LocaleKeys.auto_screen_burnin_test_warning_text.trans(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textMutedColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(true),
                            icon: const Icon(Icons.warning_amber),
                            label: Text(
                              LocaleKeys.auto_screen_burnin_test_has_issue.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.failLight,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(false),
                            icon: const Icon(Icons.skip_next),
                            label: Text(
                              LocaleKeys.auto_screen_burnin_test_skip.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
