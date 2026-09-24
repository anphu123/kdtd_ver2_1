import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/device_specs_confirmation/device_specs_confirmation_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_binding.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_page.dart';
import 'package:kdtd_ver2_1/app/modules/employee_code/employee_code_binding.dart';
import 'package:kdtd_ver2_1/app/modules/employee_code/employee_code_page.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_binding.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_page.dart';
import 'package:kdtd_ver2_1/app/modules/pre_test_guide/pre_test_guide_page.dart';
import 'package:kdtd_ver2_1/app/modules/serial_check/serial_check_binding.dart';
import 'package:kdtd_ver2_1/app/modules/serial_check/serial_check_page.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_binding.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_page.dart';
import 'package:kdtd_ver2_1/app/modules/welcome/welcome_page.dart';

import 'app_routes.dart';

/// App Pages - Cấu hình định tuyến (routes) của ứng dụng
class AppPages {
  AppPages._();

  /// Tuyến đường khởi tạo ban đầu — màn giới thiệu chương trình.
  static const String initial = AppRoutes.welcome;

  /// Danh sách tất cả các trang/tuyến đường trong ứng dụng
  static final List<GetPage> routes = [
    // Màn mở đầu giới thiệu chương trình nâng cấp
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
    ),

    // Màn hình tổng quan kiểm định (Home Dashboard)
    GetPage(
      name: AppRoutes.diagnosticsHome,
      page: () => const DiagnosticsHomePage(),
      binding: DiagnosticsHomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Màn hình nhập serial xét điều kiện chương trình nâng cấp
    GetPage(
      name: AppRoutes.serialCheck,
      page: () => const SerialCheckPage(),
      binding: SerialCheckBinding(),
      transition: Transition.rightToLeft,
    ),

    // Màn hình kiểm tra & cấp quyền thiết bị
    GetPage(
      name: AppRoutes.permissionCheck,
      page: () => const PermissionCheckPage(),
      binding: PermissionCheckBinding(),
      transition: Transition.rightToLeft,
    ),

    // Các màn hình trung gian (Xác nhận cấu hình, Hướng dẫn chuẩn bị, v.v.)
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

    // Màn nhập mã số nhân viên để chốt đổi máy
    GetPage(
      name: AppRoutes.employeeCode,
      page: () => const EmployeeCodePage(),
      binding: EmployeeCodeBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
