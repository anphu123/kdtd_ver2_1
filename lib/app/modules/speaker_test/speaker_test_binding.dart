import 'package:get/get.dart';

import 'speaker_test_controller.dart';

class SpeakerTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpeakerTestController());
  }
}
