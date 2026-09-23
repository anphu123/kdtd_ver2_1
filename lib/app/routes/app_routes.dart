/// Quản lý tuyến đường tập trung của ứng dụng (Application Routes)
///
/// Tuân thủ quy chuẩn đặt tên và điều hướng của GetX
abstract class AppRoutes {
  AppRoutes._();

  // Tên các tuyến đường chính
  static const String initial = '/';
  static const String home = '/home';

  // Tuyến đường kiểm định (Diagnostics)
  static const String diagnosticsHome = '/diagnostics/home';
  static const String serialCheck = '/diagnostics/serial-check';
  static const String permissionCheck = '/diagnostics/permission-check';
  static const String diagnosticsAuto = '/diagnostics/auto';
  static const String diagnosticsAutoOld = '/diagnostics/autoOld';
  static const String diagnosticsDetail = '/diagnostics/detail';
  static const String deviceConfirmation = '/diagnostics/device-confirmation';
  static const String preTestGuide = '/diagnostics/pre-test-guide';
  static const String testRunner = '/diagnostics/test-runner';

  // Tuyến đường các bài test riêng lẻ
  static const String testCamera = '/test/camera';
  static const String testSpeaker = '/test/speaker';
  static const String testMicrophone = '/test/microphone';
  static const String testTouch = '/test/touch';
  static const String testEarpiece = '/test/earpiece';

  // Tuyến đường cài đặt & thông tin
  static const String settings = '/settings';
  static const String about = '/about';
}

