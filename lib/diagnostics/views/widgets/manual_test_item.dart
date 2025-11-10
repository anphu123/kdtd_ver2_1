import 'package:flutter/material.dart';
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
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
                    color: statusInfo.color.withOpacity(0.1),
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
                    color: statusInfo.color.withOpacity(0.1),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
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
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Passed',
        );
      case DiagStatus.failed:
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          label: 'Failed',
        );
      case DiagStatus.running:
        return StatusInfo(
          color: Colors.orange,
          icon: Icons.autorenew,
          label: 'Running',
        );
      case DiagStatus.skipped:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.remove_circle_outline,
          label: 'Skipped',
        );
      default:
        return StatusInfo(
          color: Colors.blue,
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

