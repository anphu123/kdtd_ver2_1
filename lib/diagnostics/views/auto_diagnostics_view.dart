import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';
import '../model/diag_step.dart';
import 'widgets/widgets.dart';

/// Auto Diagnostics View - Modern Material 3 Design
/// Modular architecture with separated widgets
class AutoDiagnosticsView extends GetView<AutoDiagnosticsController> {
  const AutoDiagnosticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

          return CustomScrollView(
            slivers: [
              // Device Info Section
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

              // Auto Suite Section
              SliverToBoxAdapter(
                child: AutoSuiteSection(
                  onStartAuto: isRunning ? null : controller.start,
                  isRunning: isRunning,
                ),
              ),

              // Manual Tests Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Manual Tests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Manual Tests List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final manualTests = steps.where((s) => s.kind == DiagKind.manual).toList();
                      if (index >= manualTests.length) return null;
                      return ManualTestItem(
                        step: manualTests[index],
                        onTap: () {
                          // TODO: Handle manual test tap
                        },
                      );
                    },
                  ),
                ),
              ),

              // Capabilities Section
              SliverToBoxAdapter(
                child: CapabilitiesSection(controller: controller),
              ),

              // Hardware Details Section
              SliverToBoxAdapter(
                child: HardwareDetailsSection(controller: controller),
              ),

              // Bottom Button
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

