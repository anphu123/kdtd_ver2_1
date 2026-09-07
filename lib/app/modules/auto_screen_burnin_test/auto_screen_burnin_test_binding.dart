import 'package:get/get.dart';

import 'auto_screen_burnin_test_controller.dart';

class AutoScreenBurnInTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AutoScreenBurnInTestController());
  }
}
