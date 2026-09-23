import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/modules/question_check/question_check_controller.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/model/question_check_item.dart';

class DiagnosticOverviewController extends GetxController {
  final diagHome = Get.find<DiagnosticsHomeController>();
  final testRunner = Get.find<TestRunnerController>();
  final questionCheck = Get.find<QuestionCheckController>();

  int get finalDeviceType => diagHome.finalDeviceType;
  RxList<DiagStep> get steps => testRunner.steps;
  RxList<QuestionCheckItem> get applicableItems => questionCheck.applicableItems;
  RxMap<String, int> get answers => questionCheck.answers;

  void restartStep(DiagStep step) async {
    await testRunner.restartStep(step);
    // testRunner tự động refresh steps nên UI sẽ update
  }

  void selectAnswer(String questionId, int value) {
    questionCheck.selectAnswer(questionId, value);
    // Lựa chọn thay đổi sẽ tự cập nhật vào answers của QuestionCheckController,
    // kéo theo tính toán overallType và finalDeviceType thay đổi theo.
  }

  void onContinuePressed() {
    Get.off(() => const DiagnosticResultPage());
  }
}
