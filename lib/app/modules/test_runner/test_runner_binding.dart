import 'package:get/get.dart';
import 'test_runner_controller.dart';

/// Binding của module kiểm tra chức năng [TestRunnerPage]
class TestRunnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestRunnerController>(() => TestRunnerController());
  }
}
