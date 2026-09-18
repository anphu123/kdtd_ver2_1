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

          // 1. Device Info Hero Card (Clean Light Minimalist)
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
                marketingName: controller.marketingName,
                deviceId: controller.deviceId,
                batteryLevel: controller.batteryLevel,
              );
            }),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 6.h)),

          // 2. Diagnostic Checks Category Grid
          const SliverToBoxAdapter(
            child: DiagnosticCategoriesSection(),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

          // 3. Action Section (Start Diagnostics CTA Button)
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

          // 4. PVI Assurance Trust & Quality Note Card
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: AppColors.tradeInEmeraldLight,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.tradeInEmeraldBorder),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.tradeInEmerald,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiêu Chuẩn Định Giá & Bảo Lãnh PVI',
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.tradeInNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Quy trình chẩn đoán không xâm lấn dữ liệu, độ chính xác cao và hỗ trợ trợ giá thu cũ lên tới 2 triệu đồng.',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.5.sp,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 24.h),
          ),
        ],
      ),
    );
  }
}
