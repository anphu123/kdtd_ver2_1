import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/constants/screen_burnin_test_constants.dart';

/// Một màu đơn sắc dùng để test màn hình (phát hiện sọc ám, pixel chết...).
class ScreenTestColor {
  final String name;
  final Color color;
  final String description;

  const ScreenTestColor(this.name, this.color, this.description);
}

/// Danh sách màu test (đơn sắc để dễ phát hiện vấn đề) — dùng chung bởi
/// [ScreenBurnInTestController] (để tính bước kế/trước) và trang (để vẽ UI).
/// Không phải `const` vì name/description dùng `.trans()`.
List<ScreenTestColor> get kScreenBurnInTestColors => [
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_black_name.trans(),
    AppColors.black,
    LocaleKeys.screen_burnin_test_color_black_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_white_name.trans(),
    AppColors.white,
    LocaleKeys.screen_burnin_test_color_white_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_red_name.trans(),
    AppColors.red,
    LocaleKeys.screen_burnin_test_color_red_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_green_name.trans(),
    AppColors.green,
    LocaleKeys.screen_burnin_test_color_green_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_blue_name.trans(),
    AppColors.blue,
    LocaleKeys.screen_burnin_test_color_blue_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_gray_name.trans(),
    AppColors.neutralGrey,
    LocaleKeys.screen_burnin_test_color_gray_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_yellow_name.trans(),
    AppColors.neutralYellow,
    LocaleKeys.screen_burnin_test_color_yellow_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_cyan_name.trans(),
    AppColors.neutralCyan,
    LocaleKeys.screen_burnin_test_color_cyan_desc.trans(),
  ),
  ScreenTestColor(
    LocaleKeys.screen_burnin_test_color_magenta_name.trans(),
    AppColors.neutralPink,
    LocaleKeys.screen_burnin_test_color_magenta_desc.trans(),
  ),
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
    currentIndex.value =
        (currentIndex.value + 1) % kScreenBurnInTestColors.length;
  }

  void previousColor() {
    currentIndex.value =
        (currentIndex.value - 1 + kScreenBurnInTestColors.length) %
        kScreenBurnInTestColors.length;
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
    _autoTimer = Timer.periodic(
      ScreenBurnInTestConstants.manualAutoModeInterval,
      (_) => nextColor(),
    );
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
