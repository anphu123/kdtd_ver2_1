import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'mic_test_controller.dart';
import 'mic_test_labels.dart';
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
///
/// Kết quả pass/fail được [MicTestController] tự chấm theo biên độ đo
/// được (dBm) ngay sau khi ghi âm xong — trang này KHÔNG có nút xác nhận
/// thủ công, chỉ hiển thị tiến trình ghi âm rồi tự đóng.
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasDetectedSound = controller.hasDetectedSound.value;
      final amplitude = controller.amplitude.value;
      final level = controller.level;
      final statusColor = micStatusColor(hasDetectedSound);
      final error = controller.error.value;
      final ready = controller.ready.value;

      return Dialog(
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: AppColors.black87,
                title: Text(LocaleKeys.mic_test_title.trans(), style: AppTextStyles.titleMedium.copyWith(color: AppColors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  onPressed: () => controller.finish(false),
                ),
                automaticallyImplyLeading: false,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Builder(
                      builder: (_) {
                        if (error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.fail,
                                  size: 64.r,
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                FilledButton.icon(
                                  onPressed: controller.start,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(LocaleKeys.mic_test_retry.trans()),
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
                                SizedBox(height: 16.h),
                                Text(
                                  LocaleKeys.mic_test_preparing.trans(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Chỉ báo trạng thái
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: hasDetectedSound
                                    ? AppColors.successSurface
                                    : AppColors.pviNavySurface,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: statusColor, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    micStatusIcon(hasDetectedSound),
                                    color: statusColor,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    micStatusText(hasDetectedSound),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 32.h),

                            // Biểu tượng micro kèm hiệu ứng phóng to/thu nhỏ theo biên độ
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final scale = 1.0 + (level * 0.5);
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 100.r,
                                    height: 100.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          hasDetectedSound
                                              ? AppColors.pass
                                              : AppColors.primary,
                                      border: Border.all(
                                        color: hasDetectedSound
                                            ? AppColors.successBorder
                                            : AppColors.pviNavyBorder,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.mic,
                                      size: 50.r,
                                      color: AppColors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 32.h),

                            // Câu hướng dẫn
                            Text(
                              LocaleKeys.mic_test_instruction_recording.trans(),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Số giây đếm ngược
                            SizedBox(height: 16.h),
                            Text(
                              '${controller.countdown.value}',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.white,
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Bộ vẽ trực quan dạng sóng âm (Waveform)
                            Container(
                              height: 80.h,
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.white10,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: CustomPaint(
                                painter: WaveformPainter(
                                  amplitudes: controller.amplitudeHistory,
                                  color:
                                      hasDetectedSound
                                          ? AppColors.pass
                                          : AppColors.info,
                                ),
                                size: Size(double.infinity, 50.h),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Các thông số đo lường
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                StatItem(
                                  label: LocaleKeys.mic_test_stat_current.trans(),
                                  value: amplitude.toStringAsFixed(0),
                                  color: AppColors.info,
                                ),
                                StatItem(
                                  label: LocaleKeys.mic_test_stat_max.trans(),
                                  value: controller.maxAmplitude.value.toStringAsFixed(
                                    0,
                                  ),
                                  color: AppColors.pass,
                                ),
                                StatItem(
                                  label: LocaleKeys.mic_test_stat_level.trans(),
                                  value: '${(level * 100).toStringAsFixed(0)}%',
                                  color: AppColors.warning,
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // Ghi chú: kết quả tự động theo biên độ đo được, không cần bấm xác nhận
                            Text(
                              LocaleKeys.mic_test_auto_result_note.trans(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
