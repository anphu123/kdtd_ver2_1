import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
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
      final errorMessage = controller.errorMessage.value;

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
                title: Text(LocaleKeys.earpiece_test_title.trans(), style: AppTextStyles.titleMedium.copyWith(color: AppColors.white)),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lỗi phát âm thanh (nếu có) — hiển thị tại chỗ thay
                        // cho snackbar, vì dialog không có Overlay riêng.
                        if (errorMessage.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.white10,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.fail),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.fail,
                                  size: 20.r,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.fail,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],

                        // Chỉ báo trạng thái
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color:
                                hasDetectedNear
                                    ? AppColors.successDarkSurface
                                    : AppColors.infoDarkSurface,
                            borderRadius: BorderRadius.circular(16.r),
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
                                color:
                                    hasDetectedNear ? AppColors.pass : AppColors.info,
                                size: 24.r,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                hasDetectedNear
                                    ? LocaleKeys.earpiece_test_status_detected.trans()
                                    : LocaleKeys.earpiece_test_status_waiting.trans(),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color:
                                      hasDetectedNear ? AppColors.pass : AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Biểu tượng điện thoại kèm hiệu ứng hoạt họa
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = isNear ? 1.1 : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 140.r,
                                height: 140.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      hasDetectedNear
                                          ? AppColors.successDarkSurface
                                          : AppColors.infoDarkSurface,
                                  border: Border.all(
                                    color:
                                        hasDetectedNear
                                            ? AppColors.pass
                                            : AppColors.info,
                                    width: isNear ? 3.w : 1.w,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      size: 70.r,
                                      color:
                                          hasDetectedNear
                                              ? AppColors.pass
                                              : AppColors.info,
                                    ),
                                    if (isNear)
                                      Positioned(
                                        top: 20.h,
                                        right: 30.w,
                                        child: Container(
                                          padding: EdgeInsets.all(6.r),
                                          decoration: const BoxDecoration(
                                            color: AppColors.warning,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.sensors,
                                            size: 16.r,
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

                        SizedBox(height: 32.h),

                        // Hướng dẫn thao tác kiểm tra
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.white10,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                hasDetectedNear
                                    ? LocaleKeys.earpiece_test_auto_finish.trans()
                                    : LocaleKeys.earpiece_test_instructions_title.trans(),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              if (!hasDetectedNear) ...[
                                _buildInstructionStep(
                                  '1',
                                  LocaleKeys.earpiece_test_step1.trans(),
                                  Icons.phone_in_talk,
                                ),
                                SizedBox(height: 8.h),
                                _buildInstructionStep(
                                  '2',
                                  LocaleKeys.earpiece_test_step2.trans(),
                                  Icons.sensors,
                                ),
                                SizedBox(height: 8.h),
                                _buildInstructionStep(
                                  '3',
                                  LocaleKeys.earpiece_test_step3.trans(),
                                  Icons.hearing,
                                ),
                              ] else
                                Text(
                                  LocaleKeys.earpiece_test_detected_instruction.trans(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white70,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Số liệu thống kê
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              LocaleKeys.earpiece_test_stat_status.trans(),
                              isNear
                                  ? LocaleKeys.earpiece_test_near.trans()
                                  : LocaleKeys.earpiece_test_far.trans(),
                              isNear ? AppColors.pass : AppColors.neutralGrey,
                            ),
                            _buildStat(
                              LocaleKeys.earpiece_test_stat_count.trans(),
                              '$nearCount',
                              AppColors.info,
                            ),
                            _buildStat(
                              LocaleKeys.earpiece_test_stat_sound.trans(),
                              isPlaying
                                  ? LocaleKeys.earpiece_test_playing.trans()
                                  : LocaleKeys.earpiece_test_stopped.trans(),
                              isPlaying ? AppColors.warning : AppColors.neutralGrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.black87,
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.finish(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.white),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        icon: const Icon(Icons.close),
                        label: Text(LocaleKeys.earpiece_test_btn_fail.trans()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => controller.finish(true),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              hasDetectedNear
                                  ? AppColors.pass
                                  : AppColors.pass,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        icon: const Icon(Icons.check),
                        label: Text(
                          hasDetectedNear
                              ? LocaleKeys.earpiece_test_btn_pass.trans()
                              : LocaleKeys.earpiece_test_btn_pass_manual.trans(),
                        ),
                      ),
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

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: BorderRadius.circular(8.r),
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
        SizedBox(width: 12.w),
        Icon(icon, color: AppColors.white70, size: 20.r),
        SizedBox(width: 8.w),
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
        SizedBox(height: 4.h),
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
