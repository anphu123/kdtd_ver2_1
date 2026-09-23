import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

/// Nhãn/màu/icon hiển thị (đã dịch) cho bài test micro trong lúc ghi âm —
/// tách khỏi UI của MicTestPage. Không còn khái niệm nhiều "phase" (chỉ
/// còn duy nhất giai đoạn ghi âm rồi tự chấm điểm), nên chỉ còn phụ thuộc
/// vào [hasDetectedSound].
String micStatusText(bool hasDetectedSound) {
  return hasDetectedSound
      ? LocaleKeys.mic_test_status_sound_detected.trans()
      : LocaleKeys.mic_test_status_listening.trans();
}

Color micStatusColor(bool hasDetectedSound) {
  return hasDetectedSound ? AppColors.pass : AppColors.info;
}

IconData micStatusIcon(bool hasDetectedSound) {
  return hasDetectedSound ? Icons.check_circle : Icons.mic;
}
