import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

/// Chấm tròn báo trang hiện tại trong onboarding (giãn ra khi active).
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.isActive,
    required this.color,
  });

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.white30,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
