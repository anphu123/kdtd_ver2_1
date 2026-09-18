import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Card dạng iOS Inset Group chuẩn PVI Assurance
/// Nhóm các phần tử liền kề nhau vào 1 card bo góc tròn với viền solid
/// và tự động chèn Divider 1px giữa các phần tử.
class PviInsetGroupCard extends StatelessWidget {
  final String? headerTitle;
  final Widget? headerTrailing;
  final List<Widget> children;
  final double? dividerIndent;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const PviInsetGroupCard({
    super.key,
    required this.children,
    this.headerTitle,
    this.headerTrailing,
    this.dividerIndent,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty && headerTitle == null) return const SizedBox.shrink();

    final List<Widget> allItems = [];

    if (headerTitle != null) {
      allItems.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  headerTitle!,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.pviNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (headerTrailing != null) headerTrailing!,
            ],
          ),
        ),
      );
    }

    for (final child in children) {
      allItems.add(
        padding != null ? Padding(padding: padding!, child: child) : child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor ?? AppColors.tradeInBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < allItems.length; i++) ...[
            allItems[i],
            if (i < allItems.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: dividerIndent ?? 0,
                color: AppColors.tradeInBorder,
              ),
          ],
        ],
      ),
    );
  }
}
