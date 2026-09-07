import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

/// Một pattern (màu) hiển thị trong bài test tự động phát hiện lỗi màn hình.
class TestPattern {
  final String name;
  final Color color;
  final String description;
  final int duration; // seconds

  TestPattern({
    required this.name,
    required this.color,
    required this.description,
    required this.duration,
  });
}

/// Một lỗi màn hình do người dùng báo cáo trong lúc test.
class ScreenDefect {
  final String type;
  final String color;
  final String description;

  ScreenDefect({
    required this.type,
    required this.color,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'color': color,
        'description': description,
      };
}

/// ============================================================
/// ScreenDefectDetectionController - Logic Tự Động Phát Hiện Lỗi Màn Hình
/// ============================================================
///
/// Tự động chạy qua từng [TestPattern] (mỗi pattern có `duration` giây riêng)
/// bằng `Timer.periodic`, cho phép người dùng báo lỗi hoặc bỏ qua bước hiện
/// tại, và khi hoàn tất bài test, pop về một `Map` mô tả kết quả (khớp với
/// cách `DiagnosticsHomeController._testScreenAuto()` đọc lại: `passed`,
/// `hasIssue`, `defects`, `defectCount`).
class ScreenDefectDetectionController extends GetxController {
  final List<TestPattern> patterns = [
    TestPattern(
      name: 'Màu đỏ',
      color: AppColors.red,
      description: 'Kiểm tra pixel đỏ, vết sốc',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xanh lá',
      color: AppColors.green,
      description: 'Kiểm tra pixel xanh lá',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xanh dương',
      color: AppColors.blue,
      description: 'Kiểm tra pixel xanh dương',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu trắng',
      color: AppColors.white,
      description: 'Kiểm tra dead pixel, vết đen',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu đen',
      color: AppColors.black,
      description: 'Kiểm tra bright pixel, chảy mực',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xám',
      color: AppColors.neutralGrey,
      description: 'Kiểm tra burn-in, vết ám',
      duration: 3,
    ),
  ];

  final currentStep = 0.obs;
  final detectedDefects = <ScreenDefect>[].obs;
  final userConfirmedDefect = false.obs;

  Timer? _autoTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoTest();
  }

  @override
  void onClose() {
    _autoTimer?.cancel();
    super.onClose();
  }

  void _startAutoTest() {
    _autoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final pattern = patterns[currentStep.value];
      if (timer.tick >= pattern.duration) {
        _autoAnalyzeScreen();
        timer.cancel();
        _nextStep();
      }
    });
  }

  /// Tự động phân tích màn hình (giả lập - trong thực tế cần camera/sensor)
  void _autoAnalyzeScreen() {
    // TODO: Implement real screen analysis using:
    // - Camera to capture screen
    // - Image processing to detect defects
    // - ML model to classify defects

    // Hiện tại: Giả lập phát hiện ngẫu nhiên (demo purpose)
    // Trong production, bỏ phần này và dùng camera thật

    // Uncomment để test auto-detection:
    // if (math.Random().nextDouble() < 0.1) { // 10% chance
    //   reportDefect();
    // }
  }

  void _nextStep() {
    if (currentStep.value < patterns.length - 1) {
      currentStep.value++;
      _startAutoTest();
    } else {
      finish();
    }
  }

  /// Bỏ qua bước hiện tại và chuyển ngay sang bước kế (hoặc kết thúc nếu
  /// đang ở bước cuối).
  void skipToNext() {
    _autoTimer?.cancel();
    _nextStep();
  }

  /// Người dùng xác nhận phát hiện lỗi ở pattern hiện tại.
  void reportDefect() {
    final pattern = patterns[currentStep.value];
    userConfirmedDefect.value = true;
    detectedDefects.add(
      ScreenDefect(
        type: _getDefectType(pattern.name),
        color: pattern.name,
        description: 'Phát hiện lỗi khi test ${pattern.name.toLowerCase()}',
      ),
    );
  }

  String _getDefectType(String colorName) {
    if (colorName.contains('đen')) return 'Chảy mực / Bright pixel';
    if (colorName.contains('trắng')) return 'Dead pixel / Vết đen';
    if (colorName.contains('xám')) return 'Burn-in / Vết ám';
    return 'Pixel lỗi / Vết sốc';
  }

  /// Kết thúc bài test và pop kết quả về màn hình gọi.
  void finish() {
    _autoTimer?.cancel();
    final hasDefects = detectedDefects.isNotEmpty;
    Get.back(result: {
      'passed': !hasDefects,
      'hasIssue': hasDefects, // Thêm field này cho rule evaluator
      'defects': detectedDefects.map((d) => d.toMap()).toList(),
      'defectCount': detectedDefects.length,
    });
  }
}
