import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;

import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diag_step_labels.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/failed_tests_warning/failed_tests_warning_page.dart';
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

  void _goToResult() {
    final failedSteps = controller.steps.where((s) => s.status == DiagStatus.failed).toList();
    if (controller.score < 70 && failedSteps.isNotEmpty) {
      Get.to(() => FailedTestsWarningPage(
        failedSteps: failedSteps,
        score: controller.score,
      ));
    } else {
      Get.to(() => const DiagnosticResultPage());
    }
  }

  /// Handle tap on a test item to restart or view details
  Future<void> _handleTestTap(DiagStep step) async {
    if (controller.isRunning.value) return;
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

  /// Xây dựng danh sách test grouped theo phase
  List<Widget> _buildGroupedList() {
    final widgets = <Widget>[];

    for (final phase in DiagPhase.values) {
      final phaseSteps = controller.stepsForPhase(phase);
      if (phaseSteps.isEmpty) continue;

      widgets.add(
        SliverToBoxAdapter(
          child: Obx(() {
            final currentSteps = controller.stepsForPhase(phase);
            final passedCount = controller.passedCountForPhase(phase);
            final totalCount = currentSteps.length;
            final isCompleted = controller.isPhaseCompleted(phase);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhaseHeader(
                  title: phase.title,
                  passedCount: passedCount,
                  totalCount: totalCount,
                  isCompleted: isCompleted,
                ),
                Padding(
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
                        ),
                        if (i < currentSteps.length - 1)
                          SizedBox(height: 8.h),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            );
          }),
        ),
      );
    }

    return widgets;
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
          // 1. Top Minimalist Stepper: Bước 3 (Kiểm định) active
          Obx(() {
            final completed = controller.completed;
            final total = controller.steps.length;
            final isAllDone = completed == total && total > 0;

            return PviModernistStepper(
              currentStep: 3,
              completedSteps: isAllDone ? const {1, 2, 3} : const {1, 2},
            );
          }),

          // 2. Scrollable Test Runner Content
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Progress indicator (có Obx nội bộ)
                const SliverToBoxAdapter(child: ProgressIndicatorSection()),

                // Quick Result Notification Banner (Reactive completed & !isRunning)
                SliverToBoxAdapter(
                  child: Obx(() {
                    final completed = controller.completed;
                    final isRunning = controller.isRunning.value;

                    if (completed == 0 || isRunning) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.tradeInEmeraldLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.tradeInEmeraldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.tradeInEmerald,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.diagnostics_home_valuation_ready_title.trans(),
                                  style: AppTextStyles.cardTitle.copyWith(
                                    color: AppColors.pviNavy,
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  LocaleKeys.diagnostics_home_valuation_ready_subtitle.trans(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _goToResult,
                            child: Text(
                              LocaleKeys.diagnostics_home_view_now.trans(),
                              style: AppTextStyles.button.copyWith(
                                fontSize: 12.5.sp,
                                color: AppColors.pviRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // Test Suite Grouped Slivers
                ..._buildGroupedList(),

                // Bottom spacing
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),

          // 3. Sticky Bottom Action Dock
          _buildBottomActionDock(),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock() {
    return Obx(() {
      final completed = controller.completed;
      final isRunning = controller.isRunning.value;

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
              if (completed > 0 && !isRunning) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton.icon(
                    onPressed: _goToResult,
                    icon: Icon(Icons.arrow_forward_rounded, size: 20.sp, color: AppColors.white),
                    label: Text(
                      LocaleKeys.diagnostics_home_view_valuation_cta.trans(),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pviRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
              ],
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: OutlinedButton(
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
                        : completed == 0
                            ? LocaleKeys.diagnostics_home_start_diagnostics.trans()
                            : LocaleKeys.diagnostics_home_restart_diagnostics.trans(),
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

