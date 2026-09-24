import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Các popup dùng chung của luồng chương trình nâng cấp.
class UpgradeProgramDialogs {
  UpgradeProgramDialogs._();

  /// Serial không nằm trong chương trình — đóng popup thì đi tiếp luồng thu cũ.
  static void showSerialNotEligibleDialog(VoidCallback onContinue) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          LocaleKeys.upgrade_program_serial_check_not_eligible_title.trans(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.tradeInNavy,
          ),
        ),
        content: Text(
          LocaleKeys.upgrade_program_serial_check_not_eligible_desc.trans(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tradeInSlate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onContinue();
            },
            child: Text(
              LocaleKeys.upgrade_program_serial_check_continue_btn.trans(),
              style: AppTextStyles.button.copyWith(
                color: AppColors.tradeInBlue,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Loại máy vượt ngưỡng cho phép của chương trình nâng cấp.
  static void showDeviceNotEligibleDialog(String grade) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          LocaleKeys.upgrade_program_device_not_eligible_title.trans(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.tradeInNavy,
          ),
        ),
        content: Text(
          LocaleKeys.upgrade_program_device_not_eligible_desc.trans(
            namedArgs: {'grade': grade},
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tradeInSlate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              LocaleKeys.upgrade_program_device_not_eligible_got_it_btn.trans(),
              style: AppTextStyles.button.copyWith(
                color: AppColors.tradeInBlue,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
