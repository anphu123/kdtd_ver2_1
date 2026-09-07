import 'package:get/get.dart';

import 'diagnostics_home_controller.dart';

/// Binding của module chẩn đoán chính — gắn [DiagnosticsHomeController]
/// khi route `AppRoutes.diagnosticsHome` được mở.
class DiagnosticsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DiagnosticsHomeController());
  }
}
