import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';

import 'diagnostics_home_controller.dart';

/// Binding của module chẩn đoán chính — gắn [DiagnosticsHomeController]
/// và [TestRunnerController] khi route `AppRoutes.diagnosticsHome` được mở.
class DiagnosticsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DiagnosticsHomeController());
    if (!Get.isRegistered<TestRunnerController>()) {
      Get.put(TestRunnerController(), permanent: true);
    }
  }
}

