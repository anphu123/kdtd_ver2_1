import 'package:get/get.dart';

import 'screen_defect_detection_controller.dart';

class ScreenDefectDetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScreenDefectDetectionController());
  }
}
