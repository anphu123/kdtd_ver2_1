import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

/// Một màu đơn sắc dùng để test màn hình (phát hiện sọc ám, pixel chết...).
class ScreenTestColor {
  final String name;
  final Color color;
  final String description;

  const ScreenTestColor(this.name, this.color, this.description);
}

/// Danh sách màu test (đơn sắc để dễ phát hiện vấn đề) — dùng chung bởi
/// [ScreenBurnInTestController] (để tính bước kế/trước) và trang (để vẽ UI).
const List<ScreenTestColor> kScreenBurnInTestColors = [
  ScreenTestColor('Đen (Black)', AppColors.black, '🔍 Kiểm tra pixel sáng bất thường'),
  ScreenTestColor('Trắng (White)', AppColors.white, '🔍 Kiểm tra pixel tối, vết ám'),
  ScreenTestColor('Đỏ (Red)', AppColors.red, '🔍 Kiểm tra kênh màu đỏ'),
  ScreenTestColor('Xanh lá (Green)', AppColors.green, '🔍 Kiểm tra kênh màu xanh lá'),
  ScreenTestColor('Xanh dương (Blue)', AppColors.blue, '🔍 Kiểm tra kênh màu xanh dương'),
  ScreenTestColor('Xám (Gray)', AppColors.neutralGrey, '🔍 Kiểm tra độ đồng đều'),
  ScreenTestColor('Vàng (Yellow)', AppColors.neutralYellow, '🔍 Kiểm tra màu ấm'),
  ScreenTestColor('Cyan', AppColors.neutralCyan, '🔍 Kiểm tra màu lạnh'),
  ScreenTestColor('Magenta', AppColors.neutralPink, '🔍 Kiểm tra màu hồng'),
];

/// ============================================================
/// ScreenBurnInTestController - Logic Bài Test Burn-In Thủ Công
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test màn hình burn-in/dead-pixel thủ công
/// (chuyển màu tới/lui, chế độ tự động, xác định kết quả) sống ở đây —
/// `ScreenBurnInTestPage` chỉ còn là UI thuần đọc `.obs` field và gọi lại
/// các method của controller.
class ScreenBurnInTestController extends GetxController {
  /// Chỉ số màu hiện tại trong [kScreenBurnInTestColors].
  final currentIndex = 0.obs;

  /// Đang tự động chuyển màu (Timer.periodic) hay không.
  final autoMode = false.obs;

  Timer? _autoTimer;

  void nextColor() {
    currentIndex.value = (currentIndex.value + 1) % kScreenBurnInTestColors.length;
  }

  void previousColor() {
    currentIndex.value =
        (currentIndex.value - 1 + kScreenBurnInTestColors.length) % kScreenBurnInTestColors.length;
  }

  void toggleAutoMode() {
    if (autoMode.value) {
      _stopAutoMode();
    } else {
      _startAutoMode();
    }
  }

  void _startAutoMode() {
    autoMode.value = true;
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (_) => nextColor());
  }

  void _stopAutoMode() {
    _autoTimer?.cancel();
    _autoTimer = null;
    autoMode.value = false;
  }

  /// Kết thúc bài test. `hasIssue`: true = có vấn đề (fail), false = không
  /// có vấn đề (pass), null = người dùng huỷ (nút "Quay lại") — pop không
  /// có kết quả trong trường hợp này.
  void finish(bool? hasIssue) {
    _stopAutoMode();
    if (hasIssue == null) {
      Get.back();
    } else {
      Get.back(result: !hasIssue);
    }
  }

  @override
  void onClose() {
    _autoTimer?.cancel();
    super.onClose();
  }
}
