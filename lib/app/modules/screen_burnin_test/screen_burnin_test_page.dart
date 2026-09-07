import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late final ScreenBurnInTestController controller = Get.find<ScreenBurnInTestController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = kScreenBurnInTestColors[controller.currentIndex.value];
      final isDark = current.color.computeLuminance() < 0.5;
      final textColor = isDark ? AppColors.white : AppColors.black;
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
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tiêu đề & hướng dẫn
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: 4),
                          Text(
                            current.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.currentIndex.value + 1}/${kScreenBurnInTestColors.length}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.previousColor,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Trước'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.toggleAutoMode,
                            icon: Icon(autoMode ? Icons.pause : Icons.play_arrow),
                            label: Text(autoMode ? 'Tạm dừng' : 'Tự động'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: autoMode ? AppColors.warning : buttonColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.nextColor,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Sau'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Quan sát kỹ màn hình\nTìm sọc, vết ám, pixel bất thường',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              // Buttons kết quả ở dưới
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warning text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚠️ Nếu phát hiện sọc dọc/ngang, vết ám, pixel chết → nhấn "Có vấn đề"\n'
                        '✅ Nếu màn hình đồng đều, không vấn đề → nhấn "Không có vấn đề"',
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.finish(false),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Không có vấn đề'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.passLight,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Back button
                    TextButton(
                      onPressed: () => controller.finish(null),
                      style: TextButton.styleFrom(
                        foregroundColor: textColor.withValues(alpha: 0.7),
                      ),
                      child: const Text('Quay lại'),
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
