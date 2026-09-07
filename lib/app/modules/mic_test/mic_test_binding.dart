import 'package:get/get.dart';

import 'mic_test_controller.dart';

class MicTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MicTestController());
  }
}
