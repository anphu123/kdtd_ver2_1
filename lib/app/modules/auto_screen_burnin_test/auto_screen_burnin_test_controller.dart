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

/// Danh sách màu test rút gọn cho chế độ auto — dùng chung bởi
/// [AutoScreenBurnInTestController] (để tính bước kế) và trang (để vẽ UI).
const List<ScreenTestColor> kAutoScreenBurnInTestColors = [
  ScreenTestColor('Đen', AppColors.black, 'Pixel sáng bất thường'),
  ScreenTestColor('Trắng', AppColors.white, 'Vết ám, burn-in'),
  ScreenTestColor('Đỏ', AppColors.red, 'Kênh màu đỏ'),
  ScreenTestColor('Xanh lá', AppColors.green, 'Kênh màu xanh lá'),
  ScreenTestColor('Xanh dương', AppColors.blue, 'Kênh màu xanh dương'),
  ScreenTestColor('Xám', AppColors.neutralGrey, 'Độ đồng đều màn hình'),
];

/// ============================================================
/// AutoScreenBurnInTestController - Logic Bài Test Burn-In Tự Động
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test màn hình burn-in tự động (đếm ngược,
/// tự động chuyển màu, tạm dừng/tiếp tục, xác định kết quả) sống ở đây —
/// `AutoScreenBurnInTestPage` chỉ còn là UI thuần đọc `.obs` field và gọi
/// lại các method của controller.
class AutoScreenBurnInTestController extends GetxController {
  /// Chỉ số màu hiện tại trong [kAutoScreenBurnInTestColors].
  final currentIndex = 0.obs;

  /// Số giây còn lại của đếm ngược trước khi bài test tự động bắt đầu.
  final countdown = 3.obs;

  /// true khi đếm ngược đã xong và bài test tự động đã bắt đầu chạy.
  final started = false.obs;

  /// Bài test tự động đang chạy (true) hay đang tạm dừng (false).
  final isRunning = true.obs;

  Timer? _countdownTimer;
  Timer? _autoTimer;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        timer.cancel();
        started.value = true;
        _startAutoTest();
      }
    });
  }

  void _startAutoTest() {
    _autoTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (currentIndex.value < kAutoScreenBurnInTestColors.length - 1) {
        currentIndex.value++;
      } else {
        // Hoàn thành - tự động PASS (nếu user không báo vấn đề)
        timer.cancel();
        finish(false); // false = không có vấn đề
      }
    });
  }

  void _stopAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = null;
    isRunning.value = false;
  }

  void pause() => _stopAutoTimer();

  void resume() {
    if (started.value) {
      isRunning.value = true;
      _startAutoTest();
    }
  }

  /// Kết thúc bài test và pop kết quả. `hasIssue`: true = có vấn đề (fail),
  /// false = không có vấn đề (pass).
  void finish(bool hasIssue) {
    _stopAutoTimer();
    Get.back(result: !hasIssue);
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _autoTimer?.cancel();
    super.onClose();
  }
}
