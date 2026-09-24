import 'package:get/get.dart';

import 'employee_code_controller.dart';

/// Binding của màn nhập mã số nhân viên.
class EmployeeCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeCodeController>(() => EmployeeCodeController());
  }
}
