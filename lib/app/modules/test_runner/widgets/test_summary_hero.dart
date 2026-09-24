import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';
import 'status_info.dart';

/// Khối tổng quan đầu màn Test Runner: vòng tiến độ lớn + bộ đếm
/// Đạt / Lỗi / Còn lại. Luôn hiện (kể cả khi chưa/đã chạy xong) và đổi sang
/// xanh lục khi toàn bộ bài đã có kết quả, đỏ nếu có bài lỗi.
class TestSummaryHero extends StatelessWidget {
  const TestSummaryHero({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TestRunnerController>();

    return Obx(() {
      final steps = controller.steps;
      final total = steps.length;
      final passed = steps.where((s) => s.status == DiagStatus.passed).length;
      final failed = steps.where((s) => s.status == DiagStatus.failed).length;
      final done = controller.completed;
      final remaining = total - done;
      final running = steps.firstWhereOrNull(
        (s) => s.status == DiagStatus.running,
      );
      final finished = total > 0 && remaining == 0;

      final Color ringColor = !finished
          ? AppColors.white
          : (failed > 0 ? AppColors.failLightest : AppColors.passAccent);

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.pviNavyLight, AppColors.pviNavyDark],
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _Ring(
                  value: total > 0 ? done / total : 0,
                  color: ringColor,
                  size: 88.r,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$done',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Text(
                        '/ $total',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white60,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey(running?.code ?? finished),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          running != null
                              ? getStatusInfo(DiagStatus.running).label
                              : getStatusInfo(
                                  finished
                                      ? (failed > 0
                                          ? DiagStatus.failed
                                          : DiagStatus.passed)
                                      : DiagStatus.pending,
                                ).label,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.white60,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          running?.title ?? '$done / $total',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _Counter(
                  value: passed,
                  info: getStatusInfo(DiagStatus.passed),
                  dark: true,
                ),
                SizedBox(width: 8.w),
                _Counter(
                  value: failed,
                  info: getStatusInfo(DiagStatus.failed),
                  dark: true,
                ),
                SizedBox(width: 8.w),
                _Counter(
                  value: remaining,
                  info: getStatusInfo(DiagStatus.pending),
                  dark: true,
                  neutral: true,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.value,
    required this.info,
    required this.dark,
    this.neutral = false,
  });

  final int value;
  final StatusInfo info;
  final bool dark;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final accent = neutral ? AppColors.white60 : info.surfaceColor;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: value.toDouble()),
              duration: const Duration(milliseconds: 350),
              builder: (_, v, __) => Text(
                '${v.round()}',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: accent,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              info.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white60,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vòng tiến độ vẽ tay, chạy mượt tới giá trị mới
class _Ring extends StatelessWidget {
  const _Ring({
    required this.value,
    required this.color,
    required this.size,
    required this.child,
  });

  final double value;
  final Color color;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, color),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.white.withValues(alpha: 0.16);
    final bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(arc, 0, math.pi * 2, false, track);
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value, false, bar);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
