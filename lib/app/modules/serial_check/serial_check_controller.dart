import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/constants/upgrade_program_constants.dart';
import 'package:kdtd_ver2_1/app/core/widgets/upgrade_program_dialogs.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';

/// Kiểm tra serial trước khi vào luồng kiểm định: đúng serial thì được tham
/// gia chương trình nâng cấp, sai thì vẫn đi tiếp luồng thu cũ thông thường.
class SerialCheckController extends GetxController {
  final serialController = TextEditingController();
  final isInputEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    serialController.addListener(() {
      isInputEmpty.value = serialController.text.trim().isEmpty;
    });
  }

  @override
  void onClose() {
    serialController.dispose();
    super.onClose();
  }

  void checkSerial() {
    final serial = serialController.text.trim();
    final homeController = Get.find<DiagnosticsHomeController>();

    if (serial == UpgradeProgramConstants.eligibleSerial) {
      homeController.serialNumber.value = serial;
      homeController.isUpgradeEligible.value = true;
      Get.toNamed(AppRoutes.permissionCheck);
      return;
    }

    // Sai serial: chỉ báo cho biết rồi đi tiếp luồng thu cũ bình thường
    homeController.serialNumber.value = serial;
    homeController.isUpgradeEligible.value = false;
    UpgradeProgramDialogs.showSerialNotEligibleDialog(() {
      Get.toNamed(AppRoutes.permissionCheck);
    });
  }
}
