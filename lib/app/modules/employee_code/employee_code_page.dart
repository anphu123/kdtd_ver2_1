import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

import 'employee_code_controller.dart';

/// Màn nhập mã số nhân viên để chốt đổi máy (UI thuần).
///
/// Thay cho `AlertDialog` cũ: bàn phím không còn che mất ô nhập, ô nhập
/// che mã và có nút hiện/ẩn, nút Xác nhận bị khoá khi chưa gõ gì, và bấm
/// Enter trên bàn phím cũng xác nhận được.
class EmployeeCodePage extends GetView<EmployeeCodeController> {
  const EmployeeCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          LocaleKeys.upgrade_program_employee_code_title.trans(),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              Icon(
                Icons.badge_rounded,
                size: 64.r,
                color: AppColors.tradeInBlue,
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.upgrade_program_employee_code_description.trans(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tradeInNavy,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Obx(
                () => TextField(
                  controller: controller.codeController,
                  autofocus: true,
                  obscureText: controller.isObscured.value,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!controller.isInputEmpty.value) controller.confirm();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.tradeInNavy,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        LocaleKeys.upgrade_program_employee_code_hint.trans(),
                    errorText: controller.errorText.value,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: AppColors.tradeInBorder,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: controller.toggleObscured,
                      icon: Icon(
                        controller.isObscured.value
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.tradeInSlate,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isInputEmpty.value ? null : controller.confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tradeInBlue,
                    disabledBackgroundColor: AppColors.tradeInBorder,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.upgrade_program_employee_code_confirm_btn
                        .trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: Get.back,
                child: Text(
                  LocaleKeys.upgrade_program_employee_code_cancel_btn.trans(),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.tradeInSlate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
