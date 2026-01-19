/// ============================================================
/// ProgressIndicatorSection - Hiển Thị Tiến Độ Kiểm Định
/// ============================================================
///
/// Widget hiển thị:
/// - Phase hiện tại đang chạy
/// - Progress bar cho phase
/// - Estimated time remaining
/// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import '../../controllers/auto_diagnostics_controller.dart';
import '../../model/diag_step.dart';

class ProgressIndicatorSection extends StatelessWidget {
  const ProgressIndicatorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AutoDiagnosticsController>();

    return Obx(() {
      final isRunning = controller.isRunning.value;
      if (!isRunning) return const SizedBox.shrink();

      final currentPhase = controller.currentPhase.value;
      final phaseProgress = controller.phaseProgress.value;
      final phaseTotal = controller.phaseTotal.value;

      final steps = controller.steps;
      final completed =
          controller.passedCount.value +
          controller.failedCount.value +
          controller.skippedCount.value;
      final total = steps.length;

      // Tính estimated time remaining
      final estimatedSeconds = _estimateRemainingTime(steps, completed);

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blue006FFD.withValues(alpha: 0.1),
              AppColors.blue006FFD.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.blue006FFD.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(currentPhase),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPhaseName(currentPhase),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '$completed/$total tests',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Phase progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phase: $phaseProgress/$phaseTotal',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              phaseTotal > 0 ? phaseProgress / phaseTotal : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            _getPhaseColor(currentPhase),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Estimated time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(estimatedSeconds),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'còn lại',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Overall progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? completed / total : 0,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(AppColors.green03B134),
                minHeight: 8,
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
        return 'Thông Tin Quan Trọng';
      case DiagPhase.connectivity:
        return 'Kết Nối';
      case DiagPhase.sensors:
        return 'Cảm Biến';
      case DiagPhase.hardware:
        return 'Phần Cứng';
      case DiagPhase.screen:
        return 'Màn Hình';
      case DiagPhase.manual:
        return 'Test Thủ Công';
    }
  }

  /// Lấy màu cho phase
  Color _getPhaseColor(DiagPhase phase) {
    switch (phase) {
      case DiagPhase.critical:
        return Colors.red;
      case DiagPhase.connectivity:
        return Colors.blue;
      case DiagPhase.sensors:
        return Colors.purple;
      case DiagPhase.hardware:
        return Colors.orange;
      case DiagPhase.screen:
        return Colors.teal;
      case DiagPhase.manual:
        return Colors.green;
    }
  }
}
