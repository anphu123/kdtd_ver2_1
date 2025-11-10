import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';

class AutoDiagnosticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AutoDiagnosticsController());
  }
}
