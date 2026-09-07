import 'package:get/get.dart';

import 'screen_burnin_test_controller.dart';

class ScreenBurnInTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScreenBurnInTestController());
  }
}
