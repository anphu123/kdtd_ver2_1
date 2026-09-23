import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'status_info.dart';

/// Animated Test Item với highlight animation khi đang chạy
class AnimatedTestItem extends StatefulWidget {
  const AnimatedTestItem({
    super.key,
    required this.step,
    required this.onTap,
    this.onRetry,
  });

  final DiagStep step;
  final VoidCallback onTap;

  /// Bấm thẳng vào huy hiệu trạng thái khi đang FAIL để chạy lại ngay —
  /// không cần mở dialog xác nhận trước.
  final VoidCallback? onRetry;

  @override
  State<AnimatedTestItem> createState() => _AnimatedTestItemState();
}

class _AnimatedTestItemState extends State<AnimatedTestItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.step.status == DiagStatus.running) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTestItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.status == DiagStatus.running &&
        oldWidget.step.status != DiagStatus.running) {
      _animationController.repeat(reverse: true);
    } else if (widget.step.status != DiagStatus.running &&
        oldWidget.step.status == DiagStatus.running) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = getStatusInfo(widget.step.status);
    final isRunning = widget.step.status == DiagStatus.running;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isRunning ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRunning ? AppColors.warning : AppColors.border,
                width: isRunning ? 2 : 1,
              ),
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Biểu tượng — icon trơn, không bọc khung/chip nền màu.
                      Icon(
                        getTestIcon(widget.step.code),
                        color: AppColors.icon,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      // Tiêu đề bài kiểm tra
                      Expanded(
                        child: Text(
                          widget.step.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Huy hiệu trạng thái — FAIL thì biến thành nút "Thử lại"
                      // bấm chạy lại ngay, không cần mở dialog xác nhận trước.
                      if (widget.step.status == DiagStatus.failed &&
                          widget.onRetry != null)
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: widget.onRetry,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusInfo.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    LocaleKeys.diagnostics_home_retry_button.trans(),
                                    style: AppTextStyles.badge.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
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
                              if (isRunning)
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
                     // Icon(Icons.chevron_right, color: AppColors.neutralGreyDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
