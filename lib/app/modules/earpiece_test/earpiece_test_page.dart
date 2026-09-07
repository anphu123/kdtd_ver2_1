import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'earpiece_test_controller.dart';

/// Test Loa trong (UI thuần)
///
/// Toàn bộ nghiệp vụ sống trong [EarpieceTestController]; widget này chỉ
/// đọc các field `.obs` qua `Obx` và gọi lại các method của controller khi
/// người dùng tương tác. `_pulseController` (animation thuần UI) vẫn nằm
/// ở đây vì cần `vsync`.
class EarpieceTestPage extends GetView<EarpieceTestController> {
  const EarpieceTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _EarpieceTestView(controller: controller);
  }
}

class _EarpieceTestView extends StatefulWidget {
  const _EarpieceTestView({required this.controller});

  final EarpieceTestController controller;

  @override
  State<_EarpieceTestView> createState() => _EarpieceTestViewState();
}

class _EarpieceTestViewState extends State<_EarpieceTestView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  EarpieceTestController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isNear = controller.isNear.value;
      final hasDetectedNear = controller.hasDetectedNear.value;
      final isPlaying = controller.isPlaying.value;
      final nearCount = controller.nearCount.value;

      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black87,
          title: const Text('Test Loa trong'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.finish(false),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasDetectedNear
                        ? AppColors.pass.withValues(alpha: 0.2)
                        : AppColors.info.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasDetectedNear ? AppColors.pass : AppColors.info,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasDetectedNear ? Icons.check_circle : Icons.sensors,
                        color: hasDetectedNear ? AppColors.pass : AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        hasDetectedNear
                            ? 'Đã phát hiện cảm biến!'
                            : 'Đang chờ phát hiện...',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: hasDetectedNear ? AppColors.pass : AppColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Animated phone icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = isNear ? 1.1 : 1.0;
                    final opacity =
                        isNear ? 1.0 : (0.5 + _pulseController.value * 0.5);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasDetectedNear
                              ? AppColors.pass.withValues(alpha: opacity * 0.3)
                              : AppColors.info.withValues(alpha: opacity * 0.3),
                          boxShadow: isNear
                              ? [
                                  BoxShadow(
                                    color: hasDetectedNear
                                        ? AppColors.pass.withValues(alpha: 0.5)
                                        : AppColors.info.withValues(alpha: 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 100,
                              color: hasDetectedNear ? AppColors.pass : AppColors.info,
                            ),
                            if (isNear)
                              Positioned(
                                top: 30,
                                right: 50,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sensors,
                                    size: 24,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        hasDetectedNear
                            ? 'Tự động kết thúc sau 3 giây...'
                            : 'Hướng dẫn',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!hasDetectedNear) ...[
                        _buildInstructionStep(
                          '1',
                          'Đặt điện thoại sát tai',
                          Icons.phone_in_talk,
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          '2',
                          'Cảm biến tiệm cận sẽ kích hoạt',
                          Icons.sensors,
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          '3',
                          'Xác nhận nghe thấy âm thanh',
                          Icons.hearing,
                        ),
                      ] else
                        Text(
                          'Đã phát hiện cảm biến tiệm cận!\nBạn có nghe thấy âm thanh từ loa trong không?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Trạng thái',
                      isNear ? 'Gần' : 'Xa',
                      isNear ? AppColors.pass : AppColors.neutralGrey,
                    ),
                    _buildStat('Số lần', '$nearCount', AppColors.info),
                    _buildStat(
                      'Âm thanh',
                      isPlaying ? 'Đang phát' : 'Dừng',
                      isPlaying ? AppColors.warning : AppColors.neutralGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.black87,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.finish(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Không đạt'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => controller.finish(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: hasDetectedNear
                          ? AppColors.pass
                          : AppColors.pass.withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(hasDetectedNear ? 'Đạt' : 'Đạt (Thủ công)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: AppColors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
