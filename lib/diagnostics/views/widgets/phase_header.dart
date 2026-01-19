import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? AppColors.green03B134.withValues(alpha: 0.1)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$passedCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.green03B134 : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
