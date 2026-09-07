import 'package:get/get.dart';

import 'keys_test_controller.dart';

class KeysTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KeysTestController());
  }
}
