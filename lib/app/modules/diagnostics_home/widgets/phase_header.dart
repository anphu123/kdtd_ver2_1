import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

class PhaseHeader extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final int passedCount;
  final int totalCount;

  const PhaseHeader({
    super.key,
    required this.title,
    this.isCompleted = false,
    this.passedCount = 0,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.green03B134.withValues(alpha: 0.1)
                    : AppColors.neutralGreyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$passedCount/$totalCount',
                style: AppTextStyles.badge.copyWith(
                  color: isCompleted ? AppColors.green03B134 : AppColors.neutralGreyDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
