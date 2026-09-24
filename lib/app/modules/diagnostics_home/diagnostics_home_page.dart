import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

import 'diagnostics_home_controller.dart';
import 'widgets/widgets.dart';

/// Trang chủ Kiểm Định Thiết Bị - Giao diện Clean Light Minimalist chuẩn Trade-In Apple
class DiagnosticsHomePage extends StatelessWidget {
  const DiagnosticsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiagnosticsHomeController>();

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        title: Text(
          LocaleKeys.diagnostics_home_header_title.trans(),
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

          // 1. Thẻ thông tin thiết bị (Thiết kế phẳng, tinh gọn)
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
                ramLabel: controller.ramGb,
                romLabel: controller.romGb,
                marketingName: controller.marketingName,
                deviceId: controller.deviceId,
                batteryLevel: controller.batteryLevel,
              );
            }),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 6.h)),

          // 2. Lưới các nhóm danh mục kiểm định
          const SliverToBoxAdapter(
            child: DiagnosticCategoriesSection(),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

          // 3. Khối hành động chính (Nút CTA Bắt đầu kiểm định)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Obx(() {
                final isRunning = controller.isRunning.value;

                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: FilledButton.icon(
                    onPressed: isRunning
                        ? null
                        : controller.startWithPermissionCheck,
                    icon: Icon(
                      isRunning
                          ? Icons.hourglass_top_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 22.sp,
                    ),
                    label: Text(
                      isRunning
                          ? LocaleKeys.diagnostics_home_auto_suite_running.trans()
                          : LocaleKeys.diagnostics_home_btn_start_diagnostics.trans(),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isRunning
                          ? AppColors.neutralGrey
                          : AppColors.pviRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 10.h)),

          // Khoảng đệm phía dưới
          SliverToBoxAdapter(
            child: SizedBox(height: 24.h),
          ),
        ],
      ),
    );
  }
}
