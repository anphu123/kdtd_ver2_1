/// Hằng số dùng trong luồng kiểm định thiết bị (DiagnosticsHome).
class DiagnosticsConstants {
  DiagnosticsConstants._();

  /// Kênh giao tiếp native cho các thao tác kiểm định.
  static const String methodChannelName = 'com.fidobox/diagnostics';

  /// Nhịp tối thiểu giữa các bước test tự động (ms), tránh UI nháy quá nhanh.
  static const int minStepPacingMs = 800;

  /// Thời gian nghỉ giữa 2 bước test để người dùng kịp quan sát kết quả.
  static const Duration stepGapDuration = Duration(milliseconds: 250);

  /// Dung lượng RAM/ROM chuẩn (GiB) dùng để làm tròn giá trị đo được.
  static const List<int> standardStorageSizesGiB = [
    2,
    3,
    4,
    6,
    8,
    12,
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
  ];

  /// SDK Android tối thiểu đạt yêu cầu (Android 5.0).
  static const int minAndroidSdk = 21;

  /// Phiên bản iOS tối thiểu đạt yêu cầu.
  static const int minIosMajorVersion = 10;

  /// Các loại sóng di động được coi là 3G trở lên.
  static const List<String> radios3GOrHigher = [
    'HSPA',
    'HSDPA',
    'HSUPA',
    'HSPAP',
    'LTE',
    'NR',
  ];

  // ==================== NGÂN SÁCH THỜI GIAN BÀI BLUETOOTH ====================
  //
  // BA hằng số dưới đây ràng buộc lẫn nhau:
  //   bluetoothAdapterStateTimeout + bluetoothScanDuration < bluetoothStepTimeout
  // Vi phạm là bài test hết giờ và bị chấm FAIL dù Bluetooth hoạt động tốt —
  // từng xảy ra thật khi nâng hạn chờ adapter lên 4s mà quên bước chỉ có 5s.
  // test/diagnostics_constants_test.dart canh ràng buộc này.

  /// Hạn chờ adapter Bluetooth báo trạng thái thật (khác `unknown`).
  ///
  /// CoreBluetooth trên iOS thường báo `poweredOn` trong vài trăm mili-giây
  /// sau khi tạo CBCentralManager; 3 giây là dư dả cho máy chậm.
  static const Duration bluetoothAdapterStateTimeout = Duration(seconds: 3);

  /// Chu kỳ đọc lại trạng thái adapter trong lúc chờ.
  static const Duration bluetoothAdapterPollInterval = Duration(
    milliseconds: 100,
  );

  /// Thời hạn của cả bài test Bluetooth.
  static const Duration bluetoothStepTimeout = Duration(seconds: 10);

  /// Thời lượng quét thiết bị Bluetooth lân cận.
  static const Duration bluetoothScanDuration = Duration(seconds: 2);

  /// Thời gian lắng nghe cảm biến để xác nhận có hoạt động.
  static const Duration sensorPingDuration = Duration(milliseconds: 300);
}
