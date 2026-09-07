import 'package:get/get.dart';

import 'earpiece_test_controller.dart';

class EarpieceTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EarpieceTestController());
  }
}
