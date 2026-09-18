/// ============================================================
/// ProgressIndicatorSection - Hiển Thị Tiến Độ Kiểm Định
/// ============================================================
///
/// Widget hiển thị:
/// - Phase hiện tại đang chạy
/// - Progress bar cho phase
/// - Estimated time remaining
/// ============================================================
library;

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';

class ProgressIndicatorSection extends StatelessWidget {
  const ProgressIndicatorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TestRunnerController>();

    return Obx(() {
      final isRunning = controller.isRunning.value;
      if (!isRunning) return const SizedBox.shrink();

      final currentPhase = controller.currentPhase.value;
      final phaseProgress = controller.phaseProgress.value;
      final phaseTotal = controller.phaseTotal.value;

      final steps = controller.steps;
      final completed = controller.completed;
      final total = steps.length;

      // Tính estimated time remaining
      final estimatedSeconds = _estimateRemainingTime(steps, completed);

      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.pviNavySurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.pviNavyBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(currentPhase),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12.r,
                        height: 12.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.white),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _getPhaseName(currentPhase),
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  LocaleKeys.diagnostics_home_tests_count_label.trans(
                    namedArgs: {'completed': '$completed', 'total': '$total'},
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Phase progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.diagnostics_home_phase_progress_label.trans(
                          namedArgs: {
                            'progress': '$phaseProgress',
                            'total': '$phaseTotal',
                          },
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value:
                              phaseTotal > 0 ? phaseProgress / phaseTotal : 0,
                          backgroundColor: AppColors.neutralGreyLighter,
                          valueColor: AlwaysStoppedAnimation(
                            _getPhaseColor(currentPhase),
                          ),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Estimated time
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18.r,
                        color: AppColors.pviBlue,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatTime(estimatedSeconds),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pviBlue,
                        ),
                      ),
                      Text(
                        LocaleKeys.diagnostics_home_time_remaining_label.trans(),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Overall progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: total > 0 ? completed / total : 0,
                backgroundColor: AppColors.neutralGreyLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.green03B134),
                minHeight: 8.h,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Ước tính thời gian còn lại (giây)
  int _estimateRemainingTime(List<DiagStep> steps, int completed) {
    // Tính trung bình thời gian mỗi step đã chạy
    final completedSteps =
        steps.where((s) => s.isCompleted && s.executionTime != null).toList();

    if (completedSteps.isEmpty) {
      // Chưa có dữ liệu - estimate dựa trên timeout trung bình
      final remainingSteps = steps.where((s) => !s.isCompleted).toList();
      int totalSeconds = 0;
      for (final step in remainingSteps) {
        // Auto tests: ~2s, Manual tests: ~30s
        if (step.kind == DiagKind.auto) {
          totalSeconds += 2;
        } else {
          totalSeconds += 30;
        }
      }
      return totalSeconds;
    }

    // Có dữ liệu - tính trung bình
    final totalMs = completedSteps.fold<int>(
      0,
      (sum, s) => sum + (s.executionTime?.inMilliseconds ?? 0),
    );
    final avgMs = totalMs / completedSteps.length;

    final remaining = steps.length - completed;
    return ((remaining * avgMs) / 1000).round();
  }

  /// Format thời gian
  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '~${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) {
      return '~${minutes}m';
    }
    return '~${minutes}m ${secs}s';
  }

  /// Lấy tên phase tiếng Việt
  String _getPhaseName(DiagPhase phase) {
    switch (phase) {
      case DiagPhase.critical:
        return LocaleKeys.diagnostics_home_phase_title_critical.trans();
      case DiagPhase.connectivity:
        return LocaleKeys.diagnostics_home_phase_name_connectivity.trans();
      case DiagPhase.sensors:
        return LocaleKeys.diagnostics_home_phase_title_sensors.trans();
      case DiagPhase.hardware:
        return LocaleKeys.diagnostics_home_phase_title_hardware.trans();
      case DiagPhase.screen:
        return LocaleKeys.diagnostics_home_phase_title_screen.trans();
      case DiagPhase.manual:
        return LocaleKeys.diagnostics_home_phase_name_manual.trans();
    }
  }

  /// Lấy màu cho phase
  Color _getPhaseColor(DiagPhase phase) {
    switch (phase) {
      case DiagPhase.critical:
        return AppColors.red;
      case DiagPhase.connectivity:
        return AppColors.blue;
      case DiagPhase.sensors:
        return AppColors.neutralPurple;
      case DiagPhase.hardware:
        return AppColors.orange;
      case DiagPhase.screen:
        return AppColors.neutralTeal;
      case DiagPhase.manual:
        return AppColors.green;
    }
  }
}
