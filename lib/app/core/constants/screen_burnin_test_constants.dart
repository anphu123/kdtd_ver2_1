/// Hằng số dùng trong bài test burn-in màn hình (thủ công & tự động).
class ScreenBurnInTestConstants {
  ScreenBurnInTestConstants._();

  /// Nhịp tự động chuyển màu ở chế độ auto (bài test thủ công).
  static const Duration manualAutoModeInterval = Duration(seconds: 2);

  /// Số giây đếm ngược trước khi bài test tự động bắt đầu.
  static const int autoCountdownStartSeconds = 3;

  /// Nhịp đếm ngược (mỗi tick giảm 1 giây).
  static const Duration autoCountdownTick = Duration(seconds: 1);

  /// Nhịp tự động chuyển màu trong bài test tự động (dành cho Tier 5).
  static const Duration autoColorChangeInterval = Duration(
    milliseconds: 1500,
  );
}
