import 'package:get/get.dart';

import 'serial_check_controller.dart';

/// Binding của màn nhập serial.
class SerialCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SerialCheckController>(() => SerialCheckController());
  }
}
