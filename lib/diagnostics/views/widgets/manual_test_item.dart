import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/diag_step.dart';

/// Manual Test Item Widget
class ManualTestItem extends StatelessWidget {
  const ManualTestItem({
    super.key,
    required this.step,
    required this.onTap,
  });

  final DiagStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(step.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyE5E5E5.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(step.code),
                    color: statusInfo.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step.status == DiagStatus.running)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(statusInfo.color),
                          ),
                        )
                      else
                        Icon(
                          statusInfo.icon,
                          size: 14,
                          color: statusInfo.color,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        statusInfo.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusInfo.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray8F8F8F,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(DiagStatus status) {
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

  IconData _getIcon(String code) {
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
}

/// Status Information Helper Class
class StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
  });
}
