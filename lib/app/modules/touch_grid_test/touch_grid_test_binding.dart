import 'package:get/get.dart';

import 'touch_grid_test_controller.dart';

class TouchGridTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TouchGridTestController());
  }
}
