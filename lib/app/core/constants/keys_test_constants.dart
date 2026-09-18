/// Hằng số dùng trong bài test phím vật lý.
class KeysTestConstants {
  KeysTestConstants._();

  /// Mã phím Android cho nút Tăng âm lượng (KEYCODE_VOLUME_UP).
  static const int androidKeyCodeVolumeUp = 24;

  /// Mã phím Android cho nút Giảm âm lượng (KEYCODE_VOLUME_DOWN).
  static const int androidKeyCodeVolumeDown = 25;

  /// Thời gian chờ tối đa để nhận 1 lần bấm phím trong luồng "Chạy tự động".
  static const int keyPressTimeoutSeconds = 5;

  /// Khoảng nghỉ giữa 2 lần hỏi phím (Volume Up → Volume Down) khi chạy tự động.
  static const Duration autoSequenceGap = Duration(milliseconds: 300);
}
