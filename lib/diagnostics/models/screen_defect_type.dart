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
  static const deadPixel = 'Dead Pixel';
  static const brightPixel = 'Bright Pixel / Chảy mực';
  static const burnIn = 'Burn-in / Vết ám';
  static const colorBanding = 'Color Banding';
  static const flickering = 'Nhấp nháy';
  static const touchIssue = 'Lỗi cảm ứng';

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
  static const scratch = 'Xước';
  static const crack = 'Nứt';
  static const shattered = 'Vỡ';
  static const dent = 'Móp';

  static bool isOuterScreenDefect(String defectType) {
    return [scratch, crack, shattered, dent].contains(defectType);
  }

  static ScreenDefectSeverity getSeverity(String defectType, int count) {
    if (defectType == shattered) return ScreenDefectSeverity.severe;
    if (defectType == crack) {
      if (count >= 3) return ScreenDefectSeverity.severe;
      if (count >= 2) return ScreenDefectSeverity.moderate;
      return ScreenDefectSeverity.minor;
    }
    if (defectType == scratch) {
      if (count >= 10) return ScreenDefectSeverity.moderate;
      if (count >= 5) return ScreenDefectSeverity.minor;
      return ScreenDefectSeverity.none;
    }
    return ScreenDefectSeverity.minor;
  }
}
