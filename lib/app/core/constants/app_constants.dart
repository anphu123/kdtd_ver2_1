/// Core Constants - Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'KDTD - Device Diagnostics';
  static const String appVersion = '2.1.0';

  // API Endpoints (if any)
  static const String baseUrl = '';

  // Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastDiagnostic = 'last_diagnostic';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Limits
  static const int maxRetries = 3;
  static const int maxCacheSize = 100;
}

