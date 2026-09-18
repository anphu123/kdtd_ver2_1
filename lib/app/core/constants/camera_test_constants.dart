/// Hằng số dùng trong bài test Camera.
class CameraTestConstants {
  CameraTestConstants._();

  // ==================== CẤU HÌNH CAMERA "CHUẨN" ====================
  /// Tổng số camera coi là máy chỉ có 1 camera.
  static const int singleCameraTotal = 1;

  /// Tổng số camera coi là cấu hình 2 camera (trước/sau).
  static const int dualCameraTotal = 2;

  /// Số camera trước kỳ vọng khi tổng là [dualCameraTotal].
  static const int dualCameraExpectedFrontCount = 1;

  /// Số camera sau kỳ vọng khi tổng là [dualCameraTotal].
  static const int dualCameraExpectedBackCount = 1;

  /// Tổng số camera tối thiểu để coi là cấu hình đa camera.
  static const int multiCameraMinTotal = 3;

  /// Tổng số camera tối đa để coi là cấu hình đa camera bình thường.
  static const int multiCameraMaxTotal = 5;

  /// Số camera trước tối thiểu cho cấu hình đa camera.
  static const int multiCameraMinFrontCount = 1;

  /// Số camera sau tối thiểu cho cấu hình đa camera.
  static const int multiCameraMinBackCount = 2;

  // ==================== PHÁT HIỆN CHỐNG RUNG (OIS/EIS) ====================
  /// Số mẫu gyro tối đa lưu lại để tính variance.
  static const int gyroHistoryMaxLength = 50;

  /// Số mẫu tối thiểu cần có trước khi bắt đầu đánh giá chống rung.
  static const int gyroHistoryMinSamples = 30;

  /// Ngưỡng variance thấp cho thấy cảm biến đã được bù rung (ổn định).
  static const double gyroVarianceThreshold = 0.5;

  /// Ngưỡng biên độ gyro tối thiểu để xác nhận có rung tay thực sự.
  static const double gyroMagnitudeThreshold = 2.0;

  // ==================== NHỊP ĐỘ CÁC BƯỚC TEST ====================
  /// Thời gian hiện snackbar báo thành công cho mỗi thao tác.
  static const Duration actionSuccessSnackbarDuration = Duration(seconds: 1);

  /// Thời gian chờ trước khi tự chuyển bước sau khi chụp ảnh.
  static const Duration postCaptureDelay = Duration(seconds: 2);

  /// Thời gian chờ trước khi tự chuyển bước sau khi test focus.
  static const Duration postFocusDelay = Duration(seconds: 2);

  /// Thời gian bật đèn flash (torch) khi test flash.
  static const Duration flashTorchDuration = Duration(seconds: 1);

  /// Thời gian chờ trước khi tự chuyển bước sau khi test flash.
  static const Duration postFlashDelay = Duration(seconds: 1);
}
