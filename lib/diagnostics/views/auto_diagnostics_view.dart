// auto_diagnostics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';
import '../model/diag_step.dart';
import 'widgets/widgets.dart';

class AutoDiagnosticsView extends GetView<AutoDiagnosticsController> {
  const AutoDiagnosticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB), // nền sáng giống mock
      floatingActionButton: Obx(() {
        final completed = controller.passedCount.value +
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

          final manualTests = steps.where((s) => s.kind == DiagKind.manual).toList();

          return CustomScrollView(
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
                ),
              ),

              SliverToBoxAdapter(
                child: AutoSuiteSection(
                  onStartAuto: isRunning ? null : controller.start,
                  isRunning: isRunning,
                ),
              ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Manual Tests',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                    return ManualTestItem(
                      step: manualTests[index],
                      onTap: () {
                        // điều hướng test tay ở đây
                      },
                    );
                  },
                ),
              ),

              // (tuỳ chọn) Capabilities + Hardware Details
              SliverToBoxAdapter(child: CapabilitiesSection(controller: controller)),
              SliverToBoxAdapter(child: HardwareDetailsSection(controller: controller)),

              // Nút dưới cùng
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FilledButton(
                    onPressed: isRunning ? null : controller.start,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isRunning
                          ? 'Running Diagnostics...'
                          : completed == 0
                          ? 'Start Diagnostics'
                          : 'Restart Diagnostics',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
