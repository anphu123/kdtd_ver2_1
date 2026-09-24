import 'package:flutter/material.dart';

/// Đường cong giảm tốc dùng chung cho toàn bộ hiệu ứng vào của màn Welcome.
///
/// Tương đương `easeOutExpo`: bung rất nhanh ở đầu rồi hãm dần và dừng hẳn
/// một cách êm. `easeOutCubic` hãm sớm hơn nên phần cuối vẫn còn thấy rõ
/// bước nhảy giữa các khung hình, cảm giác hơi khựng.
const Curve kRevealCurve = Cubic(0.16, 1.0, 0.3, 1.0);

/// Bọc một widget để nó mờ dần hiện ra kèm trượt và phóng rất nhẹ, theo một
/// khoảng thời gian cắt từ [parent].
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
    this.offset = const Offset(0, 0.10),
    this.scaleFrom = 0.98,
  });

  final Animation<double> parent;

  /// Mốc bắt đầu/kết thúc trong dòng thời gian chung (0.0 - 1.0).
  ///
  /// Các khoảng nên CHỒNG LẤN nhau nhiều: phần tử sau bắt đầu vào lúc phần
  /// tử trước mới đi được nửa đường thì cả trang trôi thành một dòng liên
  /// tục, thay vì thành từng nhịp rời rạc nối đuôi nhau.
  final double start;
  final double end;

  /// Hướng trượt vào, tính theo tỉ lệ kích thước widget. Để nhỏ thôi —
  /// trượt xa trông giật, trượt gần mới ra cảm giác nổi lên.
  final Offset offset;

  /// Cỡ ban đầu. Phóng nhẹ từ 0.98 lên 1.0 làm chuyển động có chiều sâu,
  /// đỡ cảm giác phẳng như chỉ trượt đơn thuần.
  final double scaleFrom;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: parent,
      curve: Interval(start, end, curve: kRevealCurve),
    );

    // Độ mờ hãm sớm hơn vị trí: chữ hiện rõ hẳn trước khi ngừng trôi, đọc
    // được ngay thay vì phải đợi chuyển động kết thúc.
    final fade = CurvedAnimation(
      parent: parent,
      curve: Interval(
        start,
        start + (end - start) * 0.7,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: scaleFrom, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
