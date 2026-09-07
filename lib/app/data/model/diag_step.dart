/// ============================================================
/// DiagStep - Bước Kiểm Định
/// ============================================================
///
/// File này định nghĩa các model cơ bản cho quy trình kiểm định:
/// - DiagStatus: Trạng thái của bước test
/// - DiagKind: Loại test (tự động/thủ công)
/// - DiagPhase: Nhóm các test để chạy song song
/// - DiagStep: Một bước test cụ thể
/// ============================================================

/// Trạng thái của một bước kiểm định
enum DiagStatus {
  /// Đang chờ thực thi
  pending,

  /// Đang chạy
  running,

  /// Đã pass (thành công)
  passed,

  /// Đã fail (thất bại)
  failed,

  /// Đã bỏ qua (không áp dụng cho thiết bị này)
  skipped,
}

/// Loại bước kiểm định
enum DiagKind {
  /// Test tự động - không cần tương tác người dùng
  auto,

  /// Test thủ công - cần người dùng xác nhận
  manual,
}

/// Phase để nhóm các test chạy song song
/// Các test trong cùng phase sẽ được chạy song song (trừ manual)
enum DiagPhase {
  /// Phase 1: Thông tin quan trọng nhất (OS, RAM, ROM, Battery)
  critical,

  /// Phase 2: Kết nối (WiFi, Mobile, Bluetooth, NFC)
  connectivity,

  /// Phase 3: Cảm biến (GPS, Accelerometer, Gyroscope, Biometrics)
  sensors,

  /// Phase 4: Phần cứng khác (Charge, SIM, Wired, Lock, S-Pen, Vibrate)
  hardware,

  /// Phase 5: Test màn hình tự động
  screen,

  /// Phase 6: Test thủ công - chạy tuần tự
  manual,
}

/// Một bước kiểm định
class DiagStep {
  /// Mã định danh duy nhất (vd: 'battery', 'wifi', 'camera')
  final String code;

  /// Tiêu đề hiển thị cho người dùng
  final String title;

  /// Loại test: auto hoặc manual
  final DiagKind kind;

  /// Phase để nhóm test chạy song song
  final DiagPhase phase;

  /// Thời gian timeout tối đa cho test này
  final Duration timeout;

  /// Hàm thực thi cho test tự động
  final Future<bool> Function()? run;

  /// Hàm tương tác cho test thủ công
  final Future<bool> Function()? interact;

  /// Trạng thái hiện tại của step
  DiagStatus status;

  /// Ghi chú kết quả (lý do pass/fail/skip)
  String? note;

  /// Thời gian thực thi thực tế
  Duration? executionTime;

  DiagStep({
    required this.code,
    required this.title,
    required this.kind,
    this.phase = DiagPhase.hardware,
    this.timeout = const Duration(seconds: 10),
    this.run,
    this.interact,
    this.status = DiagStatus.pending,
    this.note,
    this.executionTime,
  });

  /// Reset step về trạng thái ban đầu (để chạy lại)
  void reset() {
    status = DiagStatus.pending;
    note = null;
    executionTime = null;
  }

  /// Kiểm tra step đã hoàn thành chưa
  bool get isCompleted =>
      status == DiagStatus.passed ||
      status == DiagStatus.failed ||
      status == DiagStatus.skipped;

  /// Kiểm tra step có đang chạy không
  bool get isRunning => status == DiagStatus.running;

  /// Kiểm tra step có pass không
  bool get isPassed => status == DiagStatus.passed;

  /// Kiểm tra step có fail không
  bool get isFailed => status == DiagStatus.failed;
}
