import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/global_widgets/immersive_mode.dart';

import 'screen_burnin_test_controller.dart';

/// Screen Burn-In & Dead Pixel Test (UI thuần)
/// Hiển thị các màu đơn sắc để phát hiện sọc ám, vết cháy, pixel chết.
///
/// Toàn bộ nghiệp vụ sống trong [ScreenBurnInTestController]; trang này chỉ
/// đọc `.obs` field qua `Obx` và gọi lại các method của controller khi
/// người dùng tương tác.
class ScreenBurnInTestPage extends GetView<ScreenBurnInTestController> {
  const ScreenBurnInTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImmersiveMode(child: _ScreenBurnInTestView());
  }
}

class _ScreenBurnInTestView extends StatefulWidget {
  const _ScreenBurnInTestView();

  @override
  State<_ScreenBurnInTestView> createState() => _ScreenBurnInTestViewState();
}

class _ScreenBurnInTestViewState extends State<_ScreenBurnInTestView> {
  late final ScreenBurnInTestController controller =
      Get.find<ScreenBurnInTestController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = kScreenBurnInTestColors[controller.currentIndex.value];
      final isDark = current.color.computeLuminance() < 0.5;
      final textColor = isDark ? AppColors.white : AppColors.black;
      final textMutedColor = isDark ? AppColors.white70 : AppColors.textMuted;
      final textHintColor = isDark ? AppColors.white54 : AppColors.neutralGreyDark;
      final buttonColor = isDark ? AppColors.white24 : AppColors.black12;
      final autoMode = controller.autoMode.value;

      return Scaffold(
        backgroundColor: current.color,
        body: SafeArea(
          child: Stack(
            children: [
              // Toàn màn hình một màu
              Container(color: current.color),

              // Controls ở trên
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tiêu đề & hướng dẫn
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.name,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            current.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textMutedColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${controller.currentIndex.value + 1}/${kScreenBurnInTestColors.length}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Navigation buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.previousColor,
                            icon: const Icon(Icons.arrow_back),
                            label: Text(
                              LocaleKeys.screen_burnin_test_previous.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.toggleAutoMode,
                            icon: Icon(
                              autoMode ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(
                              autoMode
                                  ? LocaleKeys
                                      .screen_burnin_test_auto_mode_pause
                                      .trans()
                                  : LocaleKeys.screen_burnin_test_auto_mode_on
                                      .trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  autoMode ? AppColors.warning : buttonColor,
                              foregroundColor: textColor,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.nextColor,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              LocaleKeys.screen_burnin_test_next.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Hướng dẫn giữa màn hình (nhỏ, mờ)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    LocaleKeys.screen_burnin_test_instruction_center.trans(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textHintColor,
                    ),
                  ),
                ),
              ),

              // Buttons kết quả ở dưới
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warning text
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        LocaleKeys.screen_burnin_test_warning_text.trans(),
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
                              LocaleKeys.screen_burnin_test_has_issue.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.failLight,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(false),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              LocaleKeys.screen_burnin_test_no_issue.trans(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.passLight,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Back button
                    TextButton(
                      onPressed: () => controller.finish(null),
                      style: TextButton.styleFrom(
                        foregroundColor: textMutedColor,
                      ),
                      child: Text(LocaleKeys.screen_burnin_test_back.trans()),
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
