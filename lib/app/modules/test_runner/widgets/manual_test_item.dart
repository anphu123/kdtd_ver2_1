import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'status_info.dart';

/// Widget mục kiểm tra thủ công
class ManualTestItem extends StatelessWidget {
  const ManualTestItem({super.key, required this.step, required this.onTap});

  final DiagStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = getStatusInfo(step.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Biểu tượng
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusInfo.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    getTestIcon(step.code),
                    color: statusInfo.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Tiêu đề bài kiểm tra
                Expanded(
                  child: Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Huy hiệu trạng thái
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusInfo.borderColor, width: 0.8),
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
                            valueColor: AlwaysStoppedAnimation(
                              statusInfo.color,
                            ),
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
                        style: AppTextStyles.badge.copyWith(
                          color: statusInfo.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Mũi tên điều hướng
                Icon(Icons.chevron_right, color: AppColors.gray8F8F8F),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
