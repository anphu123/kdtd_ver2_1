/// Ngưỡng điểm số xếp hạng thiết bị (A/B/C/D).
/// Dùng chung giữa trang kết quả thẩm định và trang cảnh báo lỗi
/// để tránh lệch ngưỡng giữa 2 màn hình.
class DiagnosticGradeConstants {
  DiagnosticGradeConstants._();

  /// Điểm tối thiểu để đạt Hạng A.
  static const int gradeAMinScore = 90;

  /// Điểm tối thiểu để đạt Hạng B.
  static const int gradeBMinScore = 80;

  /// Điểm tối thiểu để đạt Hạng C (dưới ngưỡng này là Hạng D).
  static const int gradeCMinScore = 60;
}
