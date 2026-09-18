import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';

import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/core/constants/screen_defect_detection_constants.dart';

/// Phân loại lỗi màn hình
enum ScreenDefectType {
  /// Màn hình trong (LCD/OLED panel)
  innerScreen,

  /// Màn hình ngoài (kính cường lực)
  outerScreen,
}

/// Chi tiết lỗi màn hình
class ScreenDefectDetail {
  final ScreenDefectType type;
  final String description;
  final ScreenDefectSeverity severity;
  final List<String> issues;

  ScreenDefectDetail({
    required this.type,
    required this.description,
    required this.severity,
    required this.issues,
  });

  /// Có phải lỗi nghiêm trọng không
  bool get isCritical => type == ScreenDefectType.innerScreen;

  /// Có thể thu mua không
  bool get canPurchase {
    if (type == ScreenDefectType.innerScreen) {
      return false; // Màn hình trong có lỗi → KHÔNG thu mua
    }
    // Màn hình ngoài → tùy mức độ
    return severity != ScreenDefectSeverity.severe;
  }

  /// Xếp loại thiết bị
  int get deviceGrade {
    if (type == ScreenDefectType.innerScreen) {
      return 5; // Loại 5 - Từ chối
    }

    // Màn hình ngoài
    switch (severity) {
      case ScreenDefectSeverity.none:
        return 1; // Không lỗi
      case ScreenDefectSeverity.minor:
        return 2; // Xước nhẹ
      case ScreenDefectSeverity.moderate:
        return 3; // Xước vừa
      case ScreenDefectSeverity.severe:
        return 5; // Vỡ nặng → Từ chối
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'description': description,
    'severity': severity.name,
    'issues': issues,
    'isCritical': isCritical,
    'canPurchase': canPurchase,
    'deviceGrade': deviceGrade,
  };
}

/// Mức độ nghiêm trọng
enum ScreenDefectSeverity {
  none, // Không lỗi
  minor, // Nhẹ (vài xước nhỏ)
  moderate, // Vừa (nhiều xước, vết nứt nhỏ)
  severe, // Nặng (vỡ, nứt lớn)
}

/// Các loại lỗi màn hình trong
class InnerScreenDefects {
  static String get deadPixel => LocaleKeys.screen_defect_type_dead_pixel.trans();
  static String get brightPixel =>
      LocaleKeys.screen_defect_type_bright_pixel.trans();
  static String get burnIn => LocaleKeys.screen_defect_type_burn_in.trans();
  static String get colorBanding =>
      LocaleKeys.screen_defect_type_color_banding.trans();
  static String get flickering => LocaleKeys.screen_defect_type_flickering.trans();
  static String get touchIssue =>
      LocaleKeys.screen_defect_type_touch_issue.trans();

  static bool isInnerScreenDefect(String defectType) {
    return [
      deadPixel,
      brightPixel,
      burnIn,
      colorBanding,
      flickering,
      touchIssue,
    ].contains(defectType);
  }
}

/// Các loại lỗi màn hình ngoài
class OuterScreenDefects {
  static String get scratch => LocaleKeys.screen_defect_type_scratch.trans();
  static String get crack => LocaleKeys.screen_defect_type_crack.trans();
  static String get shattered => LocaleKeys.screen_defect_type_shattered.trans();
  static String get dent => LocaleKeys.screen_defect_type_dent.trans();

  static bool isOuterScreenDefect(String defectType) {
    return [scratch, crack, shattered, dent].contains(defectType);
  }

  static ScreenDefectSeverity getSeverity(String defectType, int count) {
    if (defectType == shattered) return ScreenDefectSeverity.severe;
    if (defectType == crack) {
      if (count >= ScreenDefectSeverityThresholds.crackSevereCount) {
        return ScreenDefectSeverity.severe;
      }
      if (count >= ScreenDefectSeverityThresholds.crackModerateCount) {
        return ScreenDefectSeverity.moderate;
      }
      return ScreenDefectSeverity.minor;
    }
    if (defectType == scratch) {
      if (count >= ScreenDefectSeverityThresholds.scratchModerateCount) {
        return ScreenDefectSeverity.moderate;
      }
      if (count >= ScreenDefectSeverityThresholds.scratchMinorCount) {
        return ScreenDefectSeverity.minor;
      }
      return ScreenDefectSeverity.none;
    }
    return ScreenDefectSeverity.minor;
  }
}
