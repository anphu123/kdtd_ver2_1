import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/device_specs_confirmation/device_specs_confirmation_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_binding.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_page.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_binding.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_page.dart';
import 'package:kdtd_ver2_1/app/modules/pre_test_guide/pre_test_guide_page.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_binding.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_page.dart';

import 'app_routes.dart';

/// App Pages - Route configuration with proper structure
class AppPages {
  AppPages._();

  /// Initial route
  static const String initial = AppRoutes.diagnosticsHome;

  /// All application routes
  static final List<GetPage> routes = [
    // Diagnostics - Home Dashboard
    GetPage(
      name: AppRoutes.diagnosticsHome,
      page: () => const DiagnosticsHomePage(),
      binding: DiagnosticsHomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Permission Check Screen
    GetPage(
      name: AppRoutes.permissionCheck,
      page: () => const PermissionCheckPage(),
      binding: PermissionCheckBinding(),
      transition: Transition.rightToLeft,
    ),

    // Intermediate Screens
    GetPage(
      name: AppRoutes.deviceConfirmation,
      page: () => const DeviceSpecsConfirmationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.preTestGuide,
      page: () => const PreTestPreparationGuidePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.testRunner,
      page: () => const TestRunnerPage(),
      binding: TestRunnerBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
