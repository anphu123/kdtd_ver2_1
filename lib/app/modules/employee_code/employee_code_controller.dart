import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/upgrade_program_constants.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/app/modules/upgrade_congrats/upgrade_congrats_page.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Nghiệp vụ màn nhập mã số nhân viên để chốt đổi máy.
///
/// Trước đây bước này là một `AlertDialog` dựng vội trong
/// `UpgradeProgramDialogs`: `TextEditingController` tạo tự do trong hàm
/// static, `RxnString` treo ngoài widget tree, không khoá được nút khi ô
/// trống và không có trạng thái nào kiểm thử được. Nay tách thành module
/// riêng theo đúng khuôn mẫu các màn khác (SerialCheck) — toàn bộ trạng
/// thái sống ở đây, `EmployeeCodePage` chỉ đọc `.obs`.
class EmployeeCodeController extends GetxController {
  final codeController = TextEditingController();

  /// Ô nhập đang trống — dùng để khoá nút Xác nhận.
  final isInputEmpty = true.obs;

  /// Lỗi hiển thị dưới ô nhập (sai mã).
  final errorText = RxnString();

  /// Đang che mã khi gõ (mã nhân viên là thông tin nội bộ).
  final isObscured = true.obs;

  @override
  void onInit() {
    super.onInit();
    codeController.addListener(() {
      isInputEmpty.value = codeController.text.trim().isEmpty;
      // Gõ lại thì xoá lỗi cũ cho đỡ rối
      if (errorText.value != null) errorText.value = null;
    });
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  void toggleObscured() => isObscured.value = !isObscured.value;

  /// Xác nhận mã. Sai thì giữ nguyên màn hình và báo lỗi ngay dưới ô nhập.
  void confirm() {
    final code = codeController.text.trim();

    if (code != UpgradeProgramConstants.employeeCode) {
      codeController.clear();
      errorText.value =
          LocaleKeys.upgrade_program_employee_code_error.trans();
      return;
    }

    // Đóng màn nhập mã rồi THAY THẾ màn kết quả bằng màn chúc mừng: đã chốt
    // đổi máy thì không cho quay lại bảng kết quả nữa (giữ nguyên hành vi
    // của popup cũ).
    Get.back();
    Get.off(() => const UpgradeCongratsPage());
  }
}
