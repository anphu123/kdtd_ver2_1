import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Màn chúc mừng sau khi nhân viên xác nhận đổi máy theo chương trình nâng cấp.
class UpgradeCongratsPage extends StatelessWidget {
  const UpgradeCongratsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<DiagnosticsHomeController>();
    // Ưu tiên tên thương mại, thiếu thì lấy model, không có nữa thì tên mặc định
    final rawName =
        homeController.marketingName.isNotEmpty
            ? homeController.marketingName
            : homeController.modelName;
    final modelName =
        rawName.isNotEmpty && rawName != '-'
            ? rawName
            : LocaleKeys.diagnostic_result_default_device_name.trans();

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle,
                size: 100.r,
                color: AppColors.tradeInEmerald,
              ),
              SizedBox(height: 24.h),
              Text(
                LocaleKeys.upgrade_program_congrats_title.trans(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.tradeInNavy,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.upgrade_program_congrats_desc.trans(
                  namedArgs: {'modelName': modelName},
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tradeInSlate,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.diagnosticsHome),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tradeInBlue,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.upgrade_program_congrats_home_btn.trans(),
                  style: AppTextStyles.button.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
