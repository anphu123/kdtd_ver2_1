// auto_diagnostics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';
import '../model/diag_step.dart';
import 'widgets/widgets.dart';

class AutoDiagnosticsView extends GetView<AutoDiagnosticsController> {
  const AutoDiagnosticsView({super.key});

  /// Handle tap on a test item to restart or view details
  Future<void> _handleTestTap(DiagStep step) async {
    // If test is running, ignore tap
    if (controller.isRunning.value) return;

    // If test hasn't been run yet, ignore tap
    if (step.status == DiagStatus.pending) return;

    // Show dialog with options
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

    // If user chose to restart, run the test again
    if (result == 'restart') {
      await _restartSingleTest(step);
    }
  }

  /// Restart a single test
  Future<void> _restartSingleTest(DiagStep step) async {
    // Set status to running
    step.status = DiagStatus.running;
    step.note = null;
    controller.steps.refresh();

    bool runSuccess = false;
    try {
      if (step.kind == DiagKind.auto && step.run != null) {
        runSuccess = await step.run!();
      } else if (step.kind == DiagKind.manual && step.interact != null) {
        runSuccess = await step.interact!();
      } else {
        step.status = DiagStatus.skipped;
        step.note = 'Không có hàm thực thi';
        controller.steps.refresh();
        return;
      }
    } catch (e) {
      step.note = 'Lỗi: ${e.toString()}';
      step.status = DiagStatus.failed;
      controller.steps.refresh();
      return;
    }

    // Update status based on result
    if (runSuccess) {
      step.status = DiagStatus.passed;
      step.note = 'Test đã pass';
    } else {
      step.status = DiagStatus.failed;
      step.note = 'Test không pass';
    }

    controller.steps.refresh();

    // Recalculate counts
    controller.passedCount.value =
        controller.steps.where((s) => s.status == DiagStatus.passed).length;
    controller.failedCount.value =
        controller.steps.where((s) => s.status == DiagStatus.failed).length;
    controller.skippedCount.value =
        controller.steps.where((s) => s.status == DiagStatus.skipped).length;
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
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = ScrollController();
    final stepKeys = <String, GlobalKey>{};

    // Tạo keys cho mỗi step
    for (final step in controller.steps) {
      stepKeys[step.code] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber),
      backgroundColor: const Color(0xFFF6F7FB), // nền sáng giống mock
      floatingActionButton: Obx(() {
        final completed =
            controller.passedCount.value +
            controller.failedCount.value +
            controller.skippedCount.value;
        if (completed == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: controller.printTestResults,
          icon: const Icon(Icons.print),
          label: const Text('Print Results'),
          tooltip: 'In kết quả ra console',
        );
      }),
      body: SafeArea(
        child: Obx(() {
          final steps = controller.steps;
          final total = steps.length;
          final passed = controller.passedCount.value;
          final failed = controller.failedCount.value;
          final skipped = controller.skippedCount.value;
          final completed = passed + failed + skipped;
          final progress = total == 0 ? 0.0 : completed / total;
          final isRunning = controller.isRunning.value;

          final manualTests =
              steps.where((s) => s.kind == DiagKind.manual).toList();

          // Auto-scroll đến bước đang chạy
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentStep = steps.firstWhereOrNull(
              (s) => s.status == DiagStatus.running,
            );
            if (currentStep != null && stepKeys.containsKey(currentStep.code)) {
              final key = stepKeys[currentStep.code];
              final context = key?.currentContext;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: 0.2, // Scroll để item ở 20% từ trên xuống
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
                  onStartAuto: isRunning ? null : controller.start,
                  isRunning: isRunning,
                ),
              ),

              // Progress Navigation (nếu đã có test chạy)
              if (completed > 0 && !isRunning)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Nhấn vào test để chạy lại hoặc xem chi tiết',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Manual Tests',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList.separated(
                  itemCount: manualTests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final step = manualTests[index];
                    return AnimatedTestItem(
                      key: stepKeys[step.code],
                      step: step,
                      onTap: () => _handleTestTap(step),
                    );
                  },
                ),
              ),

              // Nút dưới cùng
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FilledButton(
                    onPressed: isRunning ? null : controller.start,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isRunning
                          ? 'Running Diagnostics...'
                          : completed == 0
                          ? 'Start Diagnostics'
                          : 'Restart Diagnostics',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
