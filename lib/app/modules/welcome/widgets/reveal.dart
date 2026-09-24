import 'package:flutter/material.dart';

/// Bọc một widget để nó mờ dần hiện ra kèm trượt nhẹ, theo một khoảng thời
/// gian cắt từ [parent].
///
/// Dùng CHUNG một AnimationController cho cả màn rồi chia khoảng bằng
/// [Interval], thay vì mỗi widget một controller: các phần tử vào so le
/// nhưng vẫn khớp nhịp tuyệt đối với nhau, và chỉ tốn một ticker.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.parent,
    required this.start,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 0.14),
  });

  final Animation<double> parent;

  /// Mốc bắt đầu/kết thúc trong dòng thời gian chung (0.0 - 1.0).
  final double start;
  final double end;

  /// Hướng trượt vào, tính theo tỉ lệ kích thước widget.
  final Offset offset;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: parent,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
