import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'status_info.dart';

/// Thẻ một bài test: ô icon nhuộm màu theo trạng thái + huy hiệu trạng thái
/// chuyển mượt (Đang chạy → Đạt/Lỗi) bằng AnimatedSwitcher. Đang chạy thì
/// viền nhấp nháy nhịp thở (chỉ đổi màu viền, không scale để khỏi giật layout).
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
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.step.status == DiagStatus.running) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTestItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final running = widget.step.status == DiagStatus.running;
    final wasRunning = oldWidget.step.status == DiagStatus.running;
    if (running && !wasRunning) {
      _pulse.repeat(reverse: true);
    } else if (!running && wasRunning) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.step.status;
    final info = getStatusInfo(status);
    final isRunning = status == DiagStatus.running;
    final isFailed = status == DiagStatus.failed;

    return PviPressable(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          Color? accent;
          if (isRunning) {
            accent = Color.lerp(
              AppColors.warningBorder,
              AppColors.warning,
              _pulse.value,
            );
          } else if (isFailed) {
            accent = AppColors.errorBorder;
          }
          return PviSurfaceCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            accent: accent,
            child: child!,
          );
        },
        child: Row(
          children: [
            _IconTile(
              code: widget.step.code,
              info: info,
              dim: status == DiagStatus.pending,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                widget.step.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder:
                  (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
              child: KeyedSubtree(
                key: ValueKey(
                  '${status.name}-${isFailed && widget.onRetry != null}',
                ),
                child:
                    isFailed && widget.onRetry != null
                        ? _RetryChip(info: info, onTap: widget.onRetry!)
                        : _StatusChip(info: info, running: isRunning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô icon bo góc nhuộm nhạt theo trạng thái (pending thì trung tính)
class _IconTile extends StatelessWidget {
  const _IconTile({required this.code, required this.info, required this.dim});

  final String code;
  final StatusInfo info;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: dim ? AppColors.surfaceSubtle : info.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        getTestIcon(code),
        size: 22.r,
        color: dim ? AppColors.pviNavy : info.color,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.info, required this.running});

  final StatusInfo info;
  final bool running;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: info.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: info.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (running)
            SizedBox(
              width: 12.r,
              height: 12.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: info.color,
              ),
            )
          else
            Icon(info.icon, size: 14.r, color: info.color),
          SizedBox(width: 6.w),
          Text(
            info.label,
            style: AppTextStyles.badge.copyWith(
              color: info.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lỗi thì huy hiệu thành nút "Thử lại" đặc màu đỏ
class _RetryChip extends StatelessWidget {
  const _RetryChip({required this.info, required this.onTap});

  final StatusInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PviPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: info.color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 14.r, color: AppColors.white),
            SizedBox(width: 6.w),
            Text(
              LocaleKeys.diagnostics_home_retry_button.trans(),
              style: AppTextStyles.badge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
