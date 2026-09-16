import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'widgets/widgets.dart';

/// Trang Dashboard Kiểm Định Thu Cũ Đổi Mới.
/// Đã được tối ưu hóa hiệu năng:
/// - Chuyển sang StatefulWidget để quản lý ScrollController và GlobalKey bền vững.
/// - Thu hẹp phạm vi Obx xuống các widget lá, loại bỏ tình trạng rebuild toàn bộ cây Sliver.
/// - Auto-scroll theo luồng phản ứng (Worker) thay vì PostFrameCallback trên mỗi lần build.
class DiagnosticsHomePage extends StatefulWidget {
  const DiagnosticsHomePage({super.key});

  @override
  State<DiagnosticsHomePage> createState() => _DiagnosticsHomePageState();
}

class _DiagnosticsHomePageState extends State<DiagnosticsHomePage> {
  late final DiagnosticsHomeController controller;
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _stepKeys = {};
  Worker? _scrollWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DiagnosticsHomeController>();
    _scrollController = ScrollController();

    for (final step in controller.steps) {
      _stepKeys[step.code] = GlobalKey();
    }

    // Lắng nghe thay đổi của step đang chạy để tự động cuộn (chỉ kích hoạt khi đổi step)
    String? lastRunningCode;
    _scrollWorker = ever<List<DiagStep>>(controller.steps, (steps) {
      final runningStep = steps.firstWhereOrNull((s) => s.status == DiagStatus.running);
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
  }

  @override
  void dispose() {
    _scrollWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
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
  List<Widget> _buildGroupedList() {
    final widgets = <Widget>[];

    for (final phase in DiagPhase.values) {
      final phaseSteps = controller.steps.where((s) => s.phase == phase).toList();
      if (phaseSteps.isEmpty) continue;

      widgets.add(
        SliverToBoxAdapter(
          child: Obx(() {
            final currentSteps = controller.steps.where((s) => s.phase == phase).toList();
            final passedCount = currentSteps.where((s) => s.status == DiagStatus.passed).length;
            final totalCount = currentSteps.length;
            final isCompleted = passedCount == totalCount && totalCount > 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhaseHeader(
                  title: _getPhaseTitle(phase),
                  passedCount: passedCount,
                  totalCount: totalCount,
                  isCompleted: isCompleted,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (int i = 0; i < currentSteps.length; i++) ...[
                        AnimatedTestItem(
                          key: _stepKeys[currentSteps[i].code],
                          step: currentSteps[i],
                          onTap: () => _handleTestTap(currentSteps[i]),
                        ),
                        if (i < currentSteps.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. Device Info Card (Reactive)
            SliverToBoxAdapter(
              child: Obx(() {
                final steps = controller.steps;
                final total = steps.length;
                final completed = controller.completed;
                final progress = total == 0 ? 0.0 : completed / total;

                return DeviceInfoSection(
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
                );
              }),
            ),

            // 2. Auto Suite 1-Click CTA (Reactive isRunning)
            SliverToBoxAdapter(
              child: Obx(() => AutoSuiteSection(
                onStartAuto: controller.isRunning.value ? null : controller.startWithPermissionCheck,
                isRunning: controller.isRunning.value,
              )),
            ),

            // 3. Progress indicator (có Obx nội bộ)
            const SliverToBoxAdapter(child: ProgressIndicatorSection()),

            // 4. Quick Result Notification Banner (Reactive completed & !isRunning)
            SliverToBoxAdapter(
              child: Obx(() {
                final completed = controller.completed;
                final isRunning = controller.isRunning.value;

                if (completed == 0 || isRunning) {
                  return const SizedBox.shrink();
                }

                return Container(
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
                );
              }),
            ),

            // 5. Test Suite Grouped Slivers
            ..._buildGroupedList(),

            // 6. Bottom Sticky / Final Action Bar (Reactive)
            SliverToBoxAdapter(
              child: Obx(() {
                final completed = controller.completed;
                final isRunning = controller.isRunning.value;

                return Padding(
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
