import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'serial_check_controller.dart';

/// Màn nhập serial để xét điều kiện tham gia chương trình nâng cấp.
class SerialCheckPage extends GetView<SerialCheckController> {
  const SerialCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          LocaleKeys.upgrade_program_serial_check_title.trans(),
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
              Text(
                LocaleKeys.upgrade_program_serial_check_description.trans(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tradeInNavy,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              TextField(
                controller: controller.serialController,
                decoration: InputDecoration(
                  hintText:
                      LocaleKeys.upgrade_program_serial_check_input_hint
                          .trans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: AppColors.tradeInBorder,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tradeInNavy,
                ),
              ),
              const Spacer(),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isInputEmpty.value
                          ? null
                          : controller.checkSerial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tradeInBlue,
                    disabledBackgroundColor: AppColors.tradeInBorder,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.upgrade_program_serial_check_button.trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                    ),
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
