import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  State<_AutoScreenBurnInTestView> createState() => _AutoScreenBurnInTestViewState();
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
                const Icon(
                  Icons.screen_search_desktop,
                  size: 80,
                  color: AppColors.white,
                ),
                const SizedBox(height: 32),
                Text(
                  'Kiểm Tra Màn Hình Tự Động',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quan sát kỹ màn hình\nTìm sọc, vết ám, pixel bất thường',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white70,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  '${controller.countdown.value}',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.infoMedium,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bắt đầu sau...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final current = kAutoScreenBurnInTestColors[controller.currentIndex.value];
      final isDark = current.color.computeLuminance() < 0.5;
      final textColor = isDark ? AppColors.white : AppColors.black;
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
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.currentIndex.value + 1}/${kAutoScreenBurnInTestColors.length} • ${current.name}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              current.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isRunning ? controller.pause : controller.resume,
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
                top: 80,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (controller.currentIndex.value + 1) / kAutoScreenBurnInTestColors.length,
                    minHeight: 8,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Tự động chuyển màu...\nChú ý quan sát',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              // Emergency buttons ở dưới
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚠️ Nếu thấy sọc/ám/pixel chết → nhấn "Có vấn đề"',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(true),
                            icon: const Icon(Icons.warning_amber),
                            label: const Text('Có vấn đề'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.failLight,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(false),
                            icon: const Icon(Icons.skip_next),
                            label: const Text('Bỏ qua'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
