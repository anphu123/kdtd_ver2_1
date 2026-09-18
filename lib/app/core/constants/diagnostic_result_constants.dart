/// Hằng số dùng trong trang kết quả thẩm định (DiagnosticResult).
class DiagnosticResultConstants {
  DiagnosticResultConstants._();

  /// Giá trị thu cũ mặc định (VNĐ) khi chưa lấy được ước tính giá từ service.
  static const int fallbackTradeInValueVnd = 5000000;

  /// Số bài test hiển thị trước khi cần bấm "Xem tất cả".
  static const int stepsPreviewLimit = 8;
}
