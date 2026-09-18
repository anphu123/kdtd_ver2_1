/// Hằng số dùng trong bài test tự động phát hiện lỗi màn hình.
class ScreenDefectDetectionConstants {
  ScreenDefectDetectionConstants._();

  /// Thời lượng hiển thị mỗi pattern màu trước khi tự chuyển bước (giây).
  static const int patternDurationSeconds = 3;

  /// Nhịp tick kiểm tra thời lượng pattern hiện tại.
  static const Duration patternTickInterval = Duration(seconds: 1);
}

/// Ngưỡng số lượng lỗi để xếp mức độ nghiêm trọng (dùng cho màn hình ngoài).
class ScreenDefectSeverityThresholds {
  ScreenDefectSeverityThresholds._();

  /// Số vết nứt (crack) từ mức này trở lên → nghiêm trọng (severe).
  static const int crackSevereCount = 3;

  /// Số vết nứt (crack) từ mức này trở lên → vừa (moderate).
  static const int crackModerateCount = 2;

  /// Số vết xước (scratch) từ mức này trở lên → vừa (moderate).
  static const int scratchModerateCount = 10;

  /// Số vết xước (scratch) từ mức này trở lên → nhẹ (minor).
  static const int scratchMinorCount = 5;
}
