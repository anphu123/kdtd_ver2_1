import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/diag_step.dart';
import 'status_info.dart';

/// Animated Test Item với highlight animation khi đang chạy
class AnimatedTestItem extends StatefulWidget {
  const AnimatedTestItem({super.key, required this.step, required this.onTap});

  final DiagStep step;
  final VoidCallback onTap;

  @override
  State<AnimatedTestItem> createState() => _AnimatedTestItemState();
}

class _AnimatedTestItemState extends State<AnimatedTestItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

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

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isRunning
                      ? [
                        BoxShadow(
                          color: AppColors.yellowFEA400.withValues(
                            alpha: 0.3 * _glowAnimation.value,
                          ),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ]
                      : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isRunning
                          ? AppColors.yellowFEA400.withValues(
                            alpha: 0.5 + (0.5 * _glowAnimation.value),
                          )
                          : AppColors.greyE5E5E5.withValues(alpha: 0.2),
                  width: isRunning ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
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
                            getTestIcon(widget.step.code),
                            color: statusInfo.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Text(
                            widget.step.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusInfo.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.chevron_right, color: AppColors.gray8F8F8F),
                      ],
                    ),
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
