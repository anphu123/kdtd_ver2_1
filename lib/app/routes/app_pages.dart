import 'package:flutter/animation.dart';
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

  // ==================== NHỊP CHUYỂN MÀN ====================

  /// Thời lượng chuyển màn.
  ///
  /// Mặc định của GetX là 300ms. Nhích lên một chút để chuyển động kịp "kể"
  /// hướng đi mà vẫn chưa bắt người dùng phải chờ — quá 500ms là thấy ì.
  static const Duration transitionDuration = Duration(milliseconds: 380);

  /// Đường cong chuyển màn.
  ///
  /// QUAN TRỌNG: `GetPage.curve` mặc định là `Curves.linear` — trang trượt
  /// đều một tốc độ rồi dừng phựt, đó là lý do chuyển màn trông khô dù đã
  /// khai báo hiệu ứng. `fastOutSlowIn` là đường cong chuẩn của Material:
  /// tăng tốc nhanh rồi hãm chậm, giống vật thể có khối lượng thật.
  static const Curve transitionCurve = Curves.fastOutSlowIn;

  /// Chuyển màn khi ĐI TIẾP một bước trong quy trình.
  ///
  /// Trượt từ phải sang kèm mờ dần. Chỉ trượt không thì hai trang cùng tông
  /// màu trông như một khối trôi ngang; thêm mờ dần mới tách bạch được đâu
  /// là trang cũ, đâu là trang mới.
  static const Transition forward = Transition.rightToLeftWithFade;

  /// Chuyển màn khi ĐỔI NGỮ CẢNH, không phải đi tiếp một bước.
  ///
  /// Ví dụ Welcome (cho khách xem) sang Trang chủ (cho kỹ thuật viên):
  /// trượt ngang hàm ý "bước kế tiếp cùng một mạch", trong khi đây là chuyển
  /// hẳn sang một không gian khác — mờ chồng hợp hơn.
  static const Transition contextSwitch = Transition.fadeIn;

  /// Gói sẵn nhịp chuyển màn cho mọi route: khỏi lặp ba tham số ở từng trang,
  /// và khỏi sót — sót một chỗ là chỗ đó rơi về `Curves.linear`.
  static GetPage<dynamic> _page({
    required String name,
    required GetPageBuilder page,
    Bindings? binding,
    Transition transition = forward,
  }) {
    return GetPage<dynamic>(
      name: name,
      page: page,
      binding: binding,
      transition: transition,
      curve: transitionCurve,
      transitionDuration: transitionDuration,
    );
  }

  /// Tuyến đường khởi tạo ban đầu — màn giới thiệu chương trình.
  static const String initial = AppRoutes.welcome;

  /// Danh sách tất cả các trang/tuyến đường trong ứng dụng
  static final List<GetPage> routes = [
    // Màn mở đầu giới thiệu chương trình nâng cấp
    _page(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
      transition: contextSwitch,
    ),

    // Màn hình tổng quan kiểm định (Home Dashboard)
    _page(
      name: AppRoutes.diagnosticsHome,
      page: () => const DiagnosticsHomePage(),
      binding: DiagnosticsHomeBinding(),
      transition: contextSwitch,
    ),

    // Màn hình nhập serial xét điều kiện chương trình nâng cấp
    _page(
      name: AppRoutes.serialCheck,
      page: () => const SerialCheckPage(),
      binding: SerialCheckBinding(),
    ),

    // Màn hình kiểm tra & cấp quyền thiết bị
    _page(
      name: AppRoutes.permissionCheck,
      page: () => const PermissionCheckPage(),
      binding: PermissionCheckBinding(),
    ),

    // Các màn hình trung gian (Xác nhận cấu hình, Hướng dẫn chuẩn bị, v.v.)
    _page(
      name: AppRoutes.deviceConfirmation,
      page: () => const DeviceSpecsConfirmationPage(),
    ),
    _page(
      name: AppRoutes.preTestGuide,
      page: () => const PreTestPreparationGuidePage(),
    ),
    _page(
      name: AppRoutes.testRunner,
      page: () => const TestRunnerPage(),
      binding: TestRunnerBinding(),
    ),

    // Màn nhập mã số nhân viên để chốt đổi máy
    _page(
      name: AppRoutes.employeeCode,
      page: () => const EmployeeCodePage(),
      binding: EmployeeCodeBinding(),
    ),
  ];
}
