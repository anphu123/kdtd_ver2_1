import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'widgets/widgets.dart';

class DiagnosticsHomePage extends GetView<DiagnosticsHomeController> {
  const DiagnosticsHomePage({super.key});

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
            Text('Status: ${_getStatusText(step.status)}'),
            if (step.note != null && step.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${step.note}'),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
          FilledButton(
            onPressed: () => Get.back(result: 'restart'),
            child: const Text('Chạy lại'),
          ),
        ],
      ),
    );

    if (result == 'restart') {
      await controller.restartStep(step);
    }
  }

  String _getStatusText(DiagStatus status) {
    switch (status) {
      case DiagStatus.passed:
        return 'PASSED';
      case DiagStatus.failed:
        return 'FAILED';
      case DiagStatus.running:
        return 'RUNNING';
      case DiagStatus.skipped:
        return 'SKIPPED';
      case DiagStatus.pending:
        return 'PENDING';
    }
  }

  String _getPhaseTitle(DiagPhase phase) {
    switch (phase) {
      case DiagPhase.critical:
        return 'Thông Tin Quan Trọng';
      case DiagPhase.connectivity:
        return 'Kết Nối & Mạng';
      case DiagPhase.sensors:
        return 'Cảm Biến';
      case DiagPhase.hardware:
        return 'Phần Cứng';
      case DiagPhase.screen:
        return 'Màn Hình';
      case DiagPhase.manual:
        return 'Kiểm Tra Chức Năng';
    }
  }

  /// Xây dựng danh sách test grouped theo phase
  List<Widget> _buildGroupedList(List<DiagStep> steps, Map<String, GlobalKey> stepKeys) {
    final widgets = <Widget>[];

    final grouped = <DiagPhase, List<DiagStep>>{};
    for (final phase in DiagPhase.values) {
      grouped[phase] = steps.where((s) => s.phase == phase).toList();
    }

    for (final phase in DiagPhase.values) {
      final phaseSteps = grouped[phase] ?? [];
      if (phaseSteps.isEmpty) continue;

      final passedCount = phaseSteps.where((s) => s.status == DiagStatus.passed).length;
      final totalCount = phaseSteps.length;
      final isCompleted = passedCount == totalCount;

      widgets.add(
        SliverToBoxAdapter(
          child: PhaseHeader(
            title: _getPhaseTitle(phase),
            passedCount: passedCount,
            totalCount: totalCount,
            isCompleted: isCompleted,
          ),
        ),
      );

      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: phaseSteps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final step = phaseSteps[index];
              return AnimatedTestItem(
                key: stepKeys[step.code],
                step: step,
                onTap: () => _handleTestTap(step),
              );
            },
          ),
        ),
      );

      widgets.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final stepKeys = <String, GlobalKey>{};

    for (final step in controller.steps) {
      stepKeys[step.code] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tradeInBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.tradeInBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thu Cũ Đổi Mới',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.tradeInNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.tradeInNavy),
        actions: [
          IconButton(
            tooltip: 'In kết quả',
            icon: const Icon(Icons.print_outlined, color: AppColors.tradeInSlate),
            onPressed: () {
              if (controller.completed == 0) {
                Get.snackbar('Thông báo', 'Chưa có kết quả kiểm định để in');
                return;
              }
              controller.printTestResults();
              Get.snackbar('Thành công', 'Đã in kết quả ra console');
            },
          ),
        ],
      ),
      backgroundColor: AppColors.tradeInSurfaceBg,
      body: SafeArea(
        child: Obx(() {
          final steps = controller.steps;
          final total = steps.length;
          final completed = controller.completed;
          final progress = total == 0 ? 0.0 : completed / total;
          final isRunning = controller.isRunning.value;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!scrollController.hasClients) return;

            final currentStep = steps.firstWhereOrNull((s) => s.status == DiagStatus.running);
            if (currentStep != null && stepKeys.containsKey(currentStep.code)) {
              final stepContext = stepKeys[currentStep.code]?.currentContext;
              if (stepContext != null) {
                Scrollable.ensureVisible(
                  stepContext,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: 0.3,
                );
              }
            }
          });

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: DeviceInfoSection(
                  modelName: controller.modelName,
                  brand: controller.brand,
                  manufacturer: controller.manufacturer,
                  platform: controller.platform,
                  progress: progress,
                  completed: completed,
                  total: total,
                  ramInfo: controller.info['ram'] as Map<String, dynamic>?,
                  romInfo: controller.info['rom'] as Map<String, dynamic>?,
                  origin: controller.origin,
                  marketingName: controller.marketingName,
                ),
              ),

              SliverToBoxAdapter(
                child: AutoSuiteSection(
                  onStartAuto: isRunning ? null : controller.startWithPermissionCheck,
                  isRunning: isRunning,
                ),
              ),

              const SliverToBoxAdapter(child: ProgressIndicatorSection()),

              if (completed > 0 && !isRunning)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tradeInEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tradeInEmerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.tradeInEmerald),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã có kết quả định giá máy!',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.tradeInNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Khám phá ngay số tiền bù để lên đời máy mới.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.neutralGreyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => const DiagnosticResultPage()),
                          child: const Text('Xem ngay'),
                        ),
                      ],
                    ),
                  ),
                ),

              ..._buildGroupedList(steps, stepKeys),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (completed > 0 && !isRunning) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: () => Get.to(() => const DiagnosticResultPage()),
                            icon: const Icon(Icons.arrow_upward_rounded),
                            label: const Text('Xem Định Giá & Lên Đời Máy Mới'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.tradeInBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: AppTextStyles.button.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: isRunning ? null : controller.startWithPermissionCheck,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isRunning
                                ? 'Đang Kiểm Định...'
                                : completed == 0
                                    ? 'Bắt Đầu Kiểm Định'
                                    : 'Kiểm Định Lại Từ Đầu',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.tradeInSlate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
