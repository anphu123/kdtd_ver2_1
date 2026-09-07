import 'dart:async';

import 'package:get/get.dart';

/// ============================================================
/// TouchGridTestController - Logic Bài Test Lưới Cảm Ứng
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test lưới cảm ứng (theo dõi ô đã chạm, bộ
/// đếm idle 5s khởi động bộ đếm ngược kết thúc 5s, tự động hoàn thành khi
/// chạm đủ 100% ô) sống ở đây — tách khỏi `TouchGridTestPage`, vốn chỉ
/// còn là UI thuần đọc các field `.obs` này. Phần tính toán layout (số
/// cột/hàng/kích thước ô từ `LayoutBuilder`) vẫn ở lại Page vì đó thuần
/// là toán bố cục, không phải nghiệp vụ.
class TouchGridTestController extends GetxController {
  /// Tập chỉ số các ô đã được chạm.
  final hitCells = <int>{}.obs;

  /// Tổng số ô của lưới — do Page tính từ kích thước màn hình rồi báo
  /// cho controller qua [setTotalCells].
  final totalCells = 0.obs;

  /// Đang trong giai đoạn đếm ngược kết thúc do không có tương tác.
  final isFinalizing = false.obs;

  /// Số giây còn lại của bộ đếm ngược kết thúc (chỉ có ý nghĩa khi
  /// [isFinalizing] là true).
  final finalizeSecondsLeft = 5.obs;

  Timer? _idleTimer;
  Timer? _finalizeTimer;

  bool get _isCurrentlyFinalizing => _finalizeTimer != null;

  @override
  void onInit() {
    super.onInit();
    _startIdleTimer();
  }

  @override
  void onClose() {
    _idleTimer?.cancel();
    _finalizeTimer?.cancel();
    super.onClose();
  }

  /// Báo cho controller biết tổng số ô của lưới (do Page tính từ kích
  /// thước màn hình). An toàn khi gọi lặp lại với cùng giá trị (vd: mỗi
  /// lần build qua LayoutBuilder) — bỏ qua nếu không đổi.
  void setTotalCells(int total) {
    if (total == totalCells.value) return;
    totalCells.value = total;
  }

  /// Đánh dấu ô [index] đã được chạm.
  void markCell(int index) {
    _onUserInteraction();

    if (hitCells.contains(index)) return;
    hitCells.add(index);

    // Đủ 100% ô → tự động kết thúc (pop true)
    if (totalCells.value > 0 && hitCells.length >= totalCells.value) {
      finish(success: true);
    }
  }

  /// Kết thúc bài test — pop kết quả ngay qua `Get.back`.
  void finish({bool success = false}) {
    _cancelIdleTimer();
    _cancelFinalizeTimer();
    final ok = success || hitCells.length >= totalCells.value;
    Get.back(result: ok);
  }

  void _onUserInteraction() {
    if (_isCurrentlyFinalizing) _cancelFinalizeTimer();
    _startIdleTimer();
  }

  void _startIdleTimer() {
    _cancelIdleTimer();
    _idleTimer = Timer(const Duration(seconds: 5), _startFinalizeTimer);
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _startFinalizeTimer() {
    _cancelFinalizeTimer();
    isFinalizing.value = true;
    finalizeSecondsLeft.value = 5;
    _finalizeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (finalizeSecondsLeft.value <= 1) {
        finish(); // kết thúc (false) khi idle
        return;
      }
      finalizeSecondsLeft.value -= 1;
    });
  }

  void _cancelFinalizeTimer() {
    _finalizeTimer?.cancel();
    _finalizeTimer = null;
    isFinalizing.value = false;
    finalizeSecondsLeft.value = 5;
  }
}
