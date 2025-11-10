/// Application Routes - Centralized route management
///
/// Following GetX best practices with proper naming convention
abstract class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  // Diagnostics Routes
  static const String diagnosticsHome = '/diagnostics/home';
  static const String diagnosticsAuto = '/diagnostics/auto';
  static const String diagnosticsAutoOld = '/diagnostics/autoOld';
  static const String diagnosticsDetail = '/diagnostics/detail';

  // Test Routes
  static const String testCamera = '/test/camera';
  static const String testSpeaker = '/test/speaker';
  static const String testMicrophone = '/test/microphone';
  static const String testTouch = '/test/touch';
  static const String testEarpiece = '/test/earpiece';

  // Settings Routes
  static const String settings = '/settings';
  static const String about = '/about';
}

