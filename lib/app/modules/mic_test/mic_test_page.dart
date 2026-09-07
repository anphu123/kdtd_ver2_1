import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'mic_test_controller.dart';
import 'widgets/stat_item.dart';
import 'widgets/waveform_painter.dart';

/// Test Micro (UI thuần)
///
/// Toàn bộ nghiệp vụ sống trong [MicTestController]; widget này chỉ đọc
/// các field `.obs` qua `Obx` và gọi lại các method của controller khi
/// người dùng tương tác. `_pulseController` (animation thuần UI) vẫn nằm
/// ở đây vì cần `vsync`; việc quan sát vòng đời ứng dụng cũng buộc phải
/// sống trong 1 `State` (`WidgetsBindingObserver`), nhưng chỉ là một
/// pass-through mỏng gọi lại controller.
class MicTestPage extends GetView<MicTestController> {
  const MicTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _MicTestView(controller: controller);
  }
}

class _MicTestView extends StatefulWidget {
  const _MicTestView({required this.controller});

  final MicTestController controller;

  @override
  State<_MicTestView> createState() => _MicTestViewState();
}

class _MicTestViewState extends State<_MicTestView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  MicTestController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      controller.onAppResumed();
    }
  }

  static String _getInstructionText(MicTestPhase phase) {
    switch (phase) {
      case MicTestPhase.recording:
        return 'Đang thu âm... Hãy nói "Một hai ba"';
      case MicTestPhase.playing:
        return 'Đang phát lại âm thanh đã thu...';
      case MicTestPhase.confirming:
        return 'Bạn có nghe thấy âm thanh vừa phát không?';
    }
  }

  static Color _getPhaseColor(MicTestPhase phase, bool hasDetectedSound) {
    switch (phase) {
      case MicTestPhase.recording:
        return hasDetectedSound ? AppColors.pass : AppColors.info;
      case MicTestPhase.playing:
        return AppColors.warning;
      case MicTestPhase.confirming:
        return AppColors.neutralPurple;
    }
  }

  static IconData _getPhaseIcon(MicTestPhase phase, bool hasDetectedSound) {
    switch (phase) {
      case MicTestPhase.recording:
        return hasDetectedSound ? Icons.check_circle : Icons.mic;
      case MicTestPhase.playing:
        return Icons.volume_up;
      case MicTestPhase.confirming:
        return Icons.help_outline;
    }
  }

  static String _getPhaseStatus(MicTestPhase phase, bool hasDetectedSound) {
    switch (phase) {
      case MicTestPhase.recording:
        return hasDetectedSound ? 'Đã phát hiện âm thanh!' : 'Đang lắng nghe...';
      case MicTestPhase.playing:
        return 'Đang phát lại...';
      case MicTestPhase.confirming:
        return 'Chờ xác nhận';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final phase = controller.phase.value;
      final hasDetectedSound = controller.hasDetectedSound.value;
      final amplitude = controller.amplitude.value;
      final level = (amplitude.clamp(0, 20000)) / 20000.0;
      final phaseColor = _getPhaseColor(phase, hasDetectedSound);
      final error = controller.error.value;
      final ready = controller.ready.value;

      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black87,
          title: const Text('Test Micro'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.finish(false),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Builder(
              builder: (_) {
                if (error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.fail,
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: controller.start,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (!ready) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Đang chuẩn bị micro...',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: phaseColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: phaseColor, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPhaseIcon(phase, hasDetectedSound),
                            color: phaseColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getPhaseStatus(phase, hasDetectedSound),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: phaseColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Animated mic icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (level * 0.5);
                        final opacity = 0.3 + (level * 0.7);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasDetectedSound
                                  ? AppColors.pass.withValues(alpha: opacity)
                                  : AppColors.info.withValues(alpha: opacity),
                              boxShadow: [
                                BoxShadow(
                                  color: hasDetectedSound
                                      ? AppColors.pass.withValues(alpha: 0.5)
                                      : AppColors.info.withValues(alpha: 0.5),
                                  blurRadius: 30 * level,
                                  spreadRadius: 10 * level,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.mic,
                              size: 60,
                              color: hasDetectedSound ? AppColors.pass : AppColors.info,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Instruction based on phase
                    Text(
                      _getInstructionText(phase),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Countdown display during recording
                    if (phase == MicTestPhase.recording) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${controller.countdown.value}',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Waveform visualizer
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomPaint(
                        painter: WaveformPainter(
                          amplitudes: controller.amplitudeHistory,
                          color: hasDetectedSound ? AppColors.pass : AppColors.info,
                        ),
                        size: const Size(double.infinity, 68),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatItem(
                          label: 'Hiện tại',
                          value: amplitude.toStringAsFixed(0),
                          color: AppColors.info,
                        ),
                        StatItem(
                          label: 'Cao nhất',
                          value: controller.maxAmplitude.value.toStringAsFixed(0),
                          color: AppColors.pass,
                        ),
                        StatItem(
                          label: 'Mức độ',
                          value: '${(level * 100).toStringAsFixed(0)}%',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ],
                );
              },
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
                    onPressed: phase == MicTestPhase.confirming
                        ? () => controller.finish(false)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledForegroundColor: AppColors.neutralGrey,
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(
                      phase == MicTestPhase.confirming ? 'Không nghe rõ' : 'Chờ...',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: phase == MicTestPhase.confirming
                        ? () => controller.finish(true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: phase == MicTestPhase.confirming
                          ? (hasDetectedSound ? AppColors.pass : AppColors.pass.withValues(alpha: 0.7))
                          : AppColors.neutralGrey,
                      disabledBackgroundColor: AppColors.neutralGrey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(
                      phase == MicTestPhase.confirming
                          ? (hasDetectedSound ? 'Nghe rõ' : 'Nghe rõ (Thủ công)')
                          : 'Chờ...',
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
