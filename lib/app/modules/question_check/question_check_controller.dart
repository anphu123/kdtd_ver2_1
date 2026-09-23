import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/data/model/question_check_item.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_overview/diagnostic_overview_page.dart';

class QuestionCheckController extends GetxController {
  final List<QuestionCheckItem> allItems = getQuestionCheckItems();
  final RxList<QuestionCheckItem> applicableItems = <QuestionCheckItem>[].obs;

  // Map from question id to the selected choice value (1-5)
  final RxMap<String, int> answers = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _filterApplicableItems();
  }

  /// Hàm heuristic nhận diện thiết bị gập (Foldable).
  /// Không phải API hệ điều hành thật, có thể sai với model lạ.
  static bool isFoldableDevice(String modelName, String marketingName) {
    final lowerModel = modelName.toLowerCase();
    final lowerMarket = marketingName.toLowerCase();
    
    final keywords = ['fold', 'flip', 'z fold', 'z flip', 'mate x', 'pixel fold'];
    
    for (final kw in keywords) {
      if (lowerModel.contains(kw) || lowerMarket.contains(kw)) {
        return true;
      }
    }
    return false;
  }

  void _filterApplicableItems() {
    final diagHomeController = Get.isRegistered<DiagnosticsHomeController>()
        ? Get.find<DiagnosticsHomeController>()
        : null;

    final isIOS = diagHomeController?.isIOS ?? false;
    final modelName = diagHomeController?.modelName ?? '';
    final marketingName = diagHomeController?.marketingName ?? '';
    final isFoldable = isFoldableDevice(modelName, marketingName);

    applicableItems.assignAll(allItems.where((item) {
      switch (item.group) {
        case QuestionGroup.general:
          return true;
        case QuestionGroup.iosOnly:
          return isIOS;
        case QuestionGroup.foldableOnly:
          return isFoldable;
      }
    }));
  }

  void selectAnswer(String questionId, int value) {
    answers[questionId] = value;
  }

  bool get isComplete {
    return applicableItems.every((item) => answers.containsKey(item.id));
  }

  int get overallType {
    if (answers.isEmpty) return 1;
    return answers.values.fold(1, (prev, curr) => curr > prev ? curr : prev);
  }

  void onContinuePressed() {
    if (!isComplete) return;
    Get.off(() => const DiagnosticOverviewPage());
  }
}
