import 'package:camera/camera.dart';
import 'package:get/get.dart';

import 'camera_test_controller.dart';

class CameraTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CameraTestController(
          cameras: Get.arguments as List<CameraDescription>,
        ));
  }
}
