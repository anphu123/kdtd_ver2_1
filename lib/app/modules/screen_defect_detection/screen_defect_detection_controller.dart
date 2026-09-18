import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/constants/screen_defect_detection_constants.dart';

/// Một pattern (màu) hiển thị trong bài test tự động phát hiện lỗi màn hình.
class TestPattern {
  final String id;
  final String name;
  final Color color;
  final String description;
  final int duration; // seconds

  TestPattern({
    required this.id,
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
      id: 'red',
      name: LocaleKeys.screen_defect_detection_pattern_red_name.trans(),
      color: AppColors.red,
      description:
          LocaleKeys.screen_defect_detection_pattern_red_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
    ),
    TestPattern(
      id: 'green',
      name: LocaleKeys.screen_defect_detection_pattern_green_name.trans(),
      color: AppColors.green,
      description:
          LocaleKeys.screen_defect_detection_pattern_green_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
    ),
    TestPattern(
      id: 'blue',
      name: LocaleKeys.screen_defect_detection_pattern_blue_name.trans(),
      color: AppColors.blue,
      description:
          LocaleKeys.screen_defect_detection_pattern_blue_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
    ),
    TestPattern(
      id: 'white',
      name: LocaleKeys.screen_defect_detection_pattern_white_name.trans(),
      color: AppColors.white,
      description:
          LocaleKeys.screen_defect_detection_pattern_white_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
    ),
    TestPattern(
      id: 'black',
      name: LocaleKeys.screen_defect_detection_pattern_black_name.trans(),
      color: AppColors.black,
      description:
          LocaleKeys.screen_defect_detection_pattern_black_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
    ),
    TestPattern(
      id: 'gray',
      name: LocaleKeys.screen_defect_detection_pattern_gray_name.trans(),
      color: AppColors.neutralGrey,
      description:
          LocaleKeys.screen_defect_detection_pattern_gray_description.trans(),
      duration: ScreenDefectDetectionConstants.patternDurationSeconds,
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
    _autoTimer = Timer.periodic(
      ScreenDefectDetectionConstants.patternTickInterval,
      (timer) {
        final pattern = patterns[currentStep.value];
        if (timer.tick >= pattern.duration) {
          _autoAnalyzeScreen();
          timer.cancel();
          _nextStep();
        }
      },
    );
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
        type: _getDefectType(pattern.id),
        color: pattern.name,
        description: LocaleKeys.screen_defect_detection_defect_description.trans(
          namedArgs: {'pattern': pattern.name.toLowerCase()},
        ),
      ),
    );
  }

  String _getDefectType(String colorId) {
    if (colorId == 'black') {
      return LocaleKeys.screen_defect_detection_defect_type_black.trans();
    }
    if (colorId == 'white') {
      return LocaleKeys.screen_defect_detection_defect_type_white.trans();
    }
    if (colorId == 'gray') {
      return LocaleKeys.screen_defect_detection_defect_type_gray.trans();
    }
    return LocaleKeys.screen_defect_detection_defect_type_default.trans();
  }

  /// Kết thúc bài test và pop kết quả về màn hình gọi.
  void finish() {
    _autoTimer?.cancel();
    final hasDefects = detectedDefects.isNotEmpty;
    Get.back(
      result: {
        'passed': !hasDefects,
        'hasIssue': hasDefects, // Thêm field này cho rule evaluator
        'defects': detectedDefects.map((d) => d.toMap()).toList(),
        'defectCount': detectedDefects.length,
      },
    );
  }
}
