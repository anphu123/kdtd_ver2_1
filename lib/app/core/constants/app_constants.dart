/// Các hằng số cốt lõi - Hằng số dùng chung toàn ứng dụng
class AppConstants {
  AppConstants._();

  // Thông tin ứng dụng
  static const String appName = 'KDTD - Device Diagnostics';
  static const String appVersion = '2.1.0';

  // Điểm cuối API (nếu có)
  static const String baseUrl = '';

  // Khóa lưu trữ cục bộ
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastDiagnostic = 'last_diagnostic';

  // Thời gian chờ (Timeouts)
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Giới hạn
  static const int maxRetries = 3;
  static const int maxCacheSize = 100;
}

