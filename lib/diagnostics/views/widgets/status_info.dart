import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/diag_step.dart';

/// Status Information Helper Class
class StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  StatusInfo({required this.color, required this.icon, required this.label});
}

/// Helper function để lấy status info từ DiagStatus
StatusInfo getStatusInfo(DiagStatus status) {
  switch (status) {
    case DiagStatus.passed:
      return StatusInfo(
        color: AppColors.green03B134,
        icon: Icons.check_circle,
        label: 'Passed',
      );
    case DiagStatus.failed:
      return StatusInfo(
        color: AppColors.redE82B2B,
        icon: Icons.cancel,
        label: 'Failed',
      );
    case DiagStatus.running:
      return StatusInfo(
        color: AppColors.yellowFEA400,
        icon: Icons.autorenew,
        label: 'Running',
      );
    case DiagStatus.skipped:
      return StatusInfo(
        color: AppColors.gray969696,
        icon: Icons.remove_circle_outline,
        label: 'Skipped',
      );
    default:
      return StatusInfo(
        color: AppColors.blue006FFD,
        icon: Icons.play_circle_outline,
        label: 'Pending',
      );
  }
}

/// Helper function để lấy icon từ test code
IconData getTestIcon(String code) {
  switch (code) {
    case 'touch':
      return Icons.touch_app;
    case 'camera':
      return Icons.camera_alt;
    case 'speaker':
      return Icons.volume_up;
    case 'mic':
      return Icons.mic;
    case 'ear':
      return Icons.hearing;
    case 'vibrate':
      return Icons.vibration;
    case 'keys':
      return Icons.keyboard;
    default:
      return Icons.check_box_outline_blank;
  }
}
