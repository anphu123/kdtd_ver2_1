import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Chấm tròn đánh số bước trong bài test camera (chờ/đang làm/đã xong).
class StepIndicator extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;

  const StepIndicator({
    super.key,
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget icon;

    if (isCompleted) {
      bgColor = AppColors.pass;
      textColor = AppColors.white;
      icon = const Icon(Icons.check, color: AppColors.white, size: 20);
    } else if (isActive) {
      bgColor = AppColors.info;
      textColor = AppColors.white;
      icon = Text(
        '$number',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      bgColor = AppColors.neutralGrey;
      textColor = AppColors.white70;
      icon = Text(
        '$number',
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: icon),
    );
  }
}
