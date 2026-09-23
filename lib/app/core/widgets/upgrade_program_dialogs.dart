import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/upgrade_program_constants.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/modules/upgrade_congrats/upgrade_congrats_page.dart';
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

  /// Nhập mã nhân viên để chốt đổi máy; sai thì báo lỗi ngay trong popup.
  static void showEmployeeCodeDialog() {
    final textController = TextEditingController();
    final errorText = RxnString();

    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          LocaleKeys.upgrade_program_employee_code_title.trans(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.tradeInNavy,
          ),
        ),
        content: Obx(
          () => TextField(
            controller: textController,
            autofocus: true,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tradeInNavy,
            ),
            decoration: InputDecoration(
              hintText: LocaleKeys.upgrade_program_employee_code_hint.trans(),
              errorText: errorText.value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            // Gõ lại thì xoá lỗi cũ cho đỡ rối
            onChanged: (_) => errorText.value = null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              LocaleKeys.upgrade_program_employee_code_cancel_btn.trans(),
              style: AppTextStyles.button.copyWith(
                color: AppColors.tradeInSlate,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tradeInBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              final code = textController.text.trim();
              if (code == UpgradeProgramConstants.employeeCode) {
                Get.back();
                Get.off(() => const UpgradeCongratsPage());
              } else {
                // Sai mã: giữ popup, xoá ô nhập để nhập lại
                textController.clear();
                errorText.value =
                    LocaleKeys.upgrade_program_employee_code_error.trans();
              }
            },
            child: Text(
              LocaleKeys.upgrade_program_employee_code_confirm_btn.trans(),
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    ).whenComplete(textController.dispose);
  }
}
