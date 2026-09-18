import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_controller.dart';

class PermissionCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionCheckController>(
      () => PermissionCheckController(),
    );
  }
}
