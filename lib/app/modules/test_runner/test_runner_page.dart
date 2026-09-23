import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;

import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diag_step_labels.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'widgets/widgets.dart';

/// Màn hình chạy test (functional diagnostics): hiển thị tiến độ + danh sách
/// step theo phase, tự cuộn tới step đang chạy.
class TestRunnerPage extends StatefulWidget {
  const TestRunnerPage({super.key});

  @override
  State<TestRunnerPage> createState() => _TestRunnerPageState();
}

class _TestRunnerPageState extends State<TestRunnerPage> {
  late final TestRunnerController controller;
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _stepKeys = {};
  Worker? _scrollWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TestRunnerController>()
        ? Get.find<TestRunnerController>()
        : Get.put(TestRunnerController());
    _scrollController = ScrollController();

    for (final step in controller.steps) {
      _stepKeys[step.code] = GlobalKey();
    }

    // Lắng nghe thay đổi của step đang chạy để tự động cuộn (chỉ kích hoạt khi đổi step)
    String? lastRunningCode;
    _scrollWorker = ever<List<DiagStep>>(controller.steps, (steps) {
      final runningStep = steps.firstWhereOrNull(
        (s) => s.status == DiagStatus.running,
      );
      if (runningStep != null && runningStep.code != lastRunningCode) {
        lastRunningCode = runningStep.code;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          final stepContext = _stepKeys[runningStep.code]?.currentContext;
          if (stepContext != null) {
            Scrollable.ensureVisible(
              stepContext,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.3,
            );
          }
        });
      }
    });

    if (!controller.isRunning.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.startFunctionalDiagnostics();
      });
    }
  }

  @override
  void dispose() {
    _scrollWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Xử lý sự kiện nhấn vào một bài test để chạy lại hoặc xem chi tiết
  Future<void> _handleTestTap(DiagStep step) async {
    if (controller.isRunning.value) return;

    // Cảm ứng màn hình là bước DUY NHẤT không tự chạy trong chuỗi tự động —
    // bấm vào đây khi đang pending chính là thao tác kích hoạt bước đó.
    if (step.phase == DiagPhase.screen && step.status == DiagStatus.pending) {
      await controller.runManualScreenStep(step);
      return;
    }

    if (step.status == DiagStatus.pending) return;

    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text(step.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.diagnostics_home_dialog_status.trans(
                namedArgs: {'status': step.status.label},
              ),
              style: AppTextStyles.bodyMedium,
            ),
            if (step.note != null && step.note!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                LocaleKeys.diagnostics_home_dialog_note.trans(
                  namedArgs: {'note': step.note!},
                ),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              LocaleKeys.diagnostics_home_close_button.trans(),
              style: AppTextStyles.button,
            ),
          ),
          FilledButton(
            onPressed: () => Get.back(result: 'restart'),
            child: Text(
              LocaleKeys.diagnostics_home_retry_button.trans(),
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );

    if (result == 'restart') {
      await controller.restartStep(step);
    }
  }

  /// Xây dựng danh sách test — 1 list liền mạch, KHÔNG chia nhóm theo phase
  /// nữa (trước đây mỗi phase có 1 PhaseHeader riêng, bị chẻ thành nhiều
  /// đoạn nhỏ rời rạc). Thứ tự lấy thẳng từ [controller.steps] — đã đúng
  /// thứ tự thực thi (wifi, bluetooth, ..., touch-screen cuối cùng).
  List<Widget> _buildGroupedList() {
    return [
      SliverToBoxAdapter(
        child: Obx(() {
          final currentSteps = controller.steps;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                for (int i = 0; i < currentSteps.length; i++) ...[
                  AnimatedTestItem(
                    key: _stepKeys.putIfAbsent(
                      currentSteps[i].code,
                      () => GlobalKey(),
                    ),
                    step: currentSteps[i],
                    onTap: () => _handleTestTap(currentSteps[i]),
                    onRetry: controller.isRunning.value
                        ? null
                        : () => controller.restartStep(currentSteps[i]),
                  ),
                  if (i < currentSteps.length - 1) SizedBox(height: 8.h),
                ],
              ],
            ),
          );
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        title: Text(
          LocaleKeys.diagnostics_home_appbar_title.trans(),
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: LocaleKeys.diagnostics_home_print_result_tooltip.trans(),
            icon: Icon(
              Icons.print_outlined,
              color: AppColors.white,
              size: 20.sp,
            ),
            onPressed: () {
              if (controller.completed == 0) {
                Get.snackbar(
                  LocaleKeys.diagnostics_home_notice_title.trans(),
                  LocaleKeys.diagnostics_home_no_result_to_print.trans(),
                );
                return;
              }
              controller.printTestResults();
              Get.snackbar(
                LocaleKeys.diagnostics_home_success_title.trans(),
                LocaleKeys.diagnostics_home_printed_to_console.trans(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Top Minimalist Stepper: Bước 2 (Kiểm định) active
          // Obx(() {
          //   final completed = controller.completed;
          //   final total = controller.steps.length;
          //   final isAllDone = completed == total && total > 0;

          //   return PviModernistStepper(
          //     currentStep: 2,
          //     completedSteps: isAllDone ? const {1, 2} : const {1},
          //   );
          // }),
            SizedBox(height: 15.h),
          // 2. Nội dung danh sách bài test có thể cuộn
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Progress indicator (có Obx nội bộ)
                const SliverToBoxAdapter(child: ProgressIndicatorSection()),

                // Danh sách Sliver các bài test theo nhóm
                ..._buildGroupedList(),

                // Khoảng đệm phía dưới
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),

          // 3. Thanh điều hướng hành động cố định bên dưới
          _buildBottomActionDock(),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock() {
    return Obx(() {
      final completed = controller.completed;
      final isRunning = controller.isRunning.value;
      final allDone = controller.allStepsCompleted;
      // Đã chạy qua ít nhất 1 lượt (không còn ở màn hình chờ bắt đầu) và
      // không còn đang chạy — lúc này việc "Bắt đầu"/"Kiểm định lại" không
      // còn ý nghĩa nữa, thay bằng nút "Tiếp tục" sang bước kế tiếp.
      final showContinue = !isRunning && completed > 0;

      if (completed == 0 && isRunning) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: showContinue
                    ? FilledButton(
                        // Chỉ bấm được khi TOÀN BỘ step đã có kết quả cuối
                        // (đạt/lỗi/bỏ qua đều được) — còn step nào pending
                        // (vd chưa bấm "Cảm ứng màn hình"/"Sinh trắc học")
                        // thì nút vẫn hiện nhưng bị khoá.
                        onPressed: allDone ? controller.continueToNextStep : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.tradeInBlue,
                          disabledBackgroundColor: AppColors.neutralGreyLighter,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          LocaleKeys.diagnostics_home_continue_diagnostics.trans(),
                          style: AppTextStyles.button.copyWith(
                            color: allDone ? AppColors.white : AppColors.textDisabled,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: isRunning ? null : controller.startWithPermissionCheck,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          isRunning
                              ? LocaleKeys.diagnostics_home_running_diagnostics.trans()
                              : LocaleKeys.diagnostics_home_start_diagnostics.trans(),
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.tradeInSlate,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

