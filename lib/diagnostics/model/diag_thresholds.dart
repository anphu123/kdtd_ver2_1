/// ============================================================
/// DiagThresholds - Ngưỡng Đánh Giá Kiểm Định
/// ============================================================
///
/// File này định nghĩa các ngưỡng (threshold) để đánh giá
/// kết quả pass/fail cho các bước kiểm định:
/// - Tín hiệu mạng di động (dBm)
/// - Độ chính xác GPS (mét)
/// - Độ nhạy cảm ứng (%)
/// - Âm thanh microphone (dB)
/// - Timeout cho các bước test
///
/// Dữ liệu được load từ assets/diag_thresholds.json
/// ============================================================

/// Ngưỡng tổng hợp cho tất cả loại test
class DiagThresholds {
  /// Ngưỡng cho test mạng di động
  final MobileThresholds mobile;

  /// Ngưỡng cho test GPS
  final GpsThresholds gps;

  /// Ngưỡng cho test cảm ứng
  final TouchThresholds touch;

  /// Ngưỡng cho test âm thanh
  final AudioThresholds audio;

  /// Ngưỡng timeout cho runner
  final RunnerThresholds runner;

  const DiagThresholds({
    required this.mobile,
    required this.gps,
    required this.touch,
    required this.audio,
    required this.runner,
  });

  /// Tạo từ JSON
  factory DiagThresholds.fromJson(Map<String, dynamic> json) {
    final t = json['thresholds'] as Map<String, dynamic>? ?? {};
    return DiagThresholds(
      mobile: MobileThresholds.fromJson(t['mobile'] ?? {}),
      gps: GpsThresholds.fromJson(t['gps'] ?? {}),
      touch: TouchThresholds.fromJson(t['touch'] ?? {}),
      audio: AudioThresholds.fromJson(t['audio'] ?? {}),
      runner: RunnerThresholds.fromJson(t['runner'] ?? {}),
    );
  }

  /// Ngưỡng mặc định (dùng khi không load được JSON)
  factory DiagThresholds.defaults() {
    return const DiagThresholds(
      mobile: MobileThresholds(dbmMin: -120, dbmMax: -40),
      gps: GpsThresholds(accuracyMPass: 50, timeoutSec: 8),
      touch: TouchThresholds(passRatioMin: 0.98),
      audio: AudioThresholds(micRmsMin: -20),
      runner: RunnerThresholds(autoStepTimeoutSec: 8),
    );
  }
}

// ==================== MOBILE THRESHOLDS ====================

/// Ngưỡng cho test mạng di động
class MobileThresholds {
  /// dBm tối thiểu chấp nhận được (-120 dBm là rất yếu)
  final int dbmMin;

  /// dBm tối đa (-40 dBm là rất mạnh)
  final int dbmMax;

  const MobileThresholds({required this.dbmMin, required this.dbmMax});

  factory MobileThresholds.fromJson(Map<String, dynamic> json) {
    return MobileThresholds(
      dbmMin: json['dbm_min'] ?? -120,
      dbmMax: json['dbm_max'] ?? -40,
    );
  }

  /// Kiểm tra tín hiệu có trong ngưỡng chấp nhận không
  bool isAcceptable(int dbm) => dbm >= dbmMin && dbm <= dbmMax;
}

// ==================== GPS THRESHOLDS ====================

/// Ngưỡng cho test GPS
class GpsThresholds {
  /// Độ chính xác tối đa để pass (mét)
  /// < 50m thường được coi là tốt
  final double accuracyMPass;

  /// Thời gian timeout để lấy vị trí (giây)
  final int timeoutSec;

  const GpsThresholds({required this.accuracyMPass, required this.timeoutSec});

  factory GpsThresholds.fromJson(Map<String, dynamic> json) {
    return GpsThresholds(
      accuracyMPass: (json['accuracy_m_pass'] ?? 50).toDouble(),
      timeoutSec: json['timeout_sec'] ?? 8,
    );
  }

  /// Kiểm tra độ chính xác có đạt không
  bool isAccurate(double meters) => meters <= accuracyMPass;
}

// ==================== TOUCH THRESHOLDS ====================

/// Ngưỡng cho test cảm ứng màn hình
class TouchThresholds {
  /// Tỷ lệ ô đã touch tối thiểu để pass (0.98 = 98%)
  final double passRatioMin;

  const TouchThresholds({required this.passRatioMin});

  factory TouchThresholds.fromJson(Map<String, dynamic> json) {
    return TouchThresholds(
      passRatioMin: (json['pass_ratio_min'] ?? 0.98).toDouble(),
    );
  }

  /// Kiểm tra tỷ lệ touch có đạt không
  bool isPassing(double ratio) => ratio >= passRatioMin;
}

// ==================== AUDIO THRESHOLDS ====================

/// Ngưỡng cho test âm thanh
class AudioThresholds {
  /// RMS tối thiểu của microphone (dB)
  /// -20 dB là mức nhỏ nhất còn nghe được
  final double micRmsMin;

  const AudioThresholds({required this.micRmsMin});

  factory AudioThresholds.fromJson(Map<String, dynamic> json) {
    return AudioThresholds(micRmsMin: (json['mic_rms_min'] ?? -20).toDouble());
  }

  /// Kiểm tra mic có hoạt động đủ tốt không
  bool isMicWorking(double rms) => rms >= micRmsMin;
}

// ==================== RUNNER THRESHOLDS ====================

/// Ngưỡng timeout cho runner thực thi test
class RunnerThresholds {
  /// Timeout mặc định cho mỗi bước auto (giây)
  final int autoStepTimeoutSec;

  const RunnerThresholds({required this.autoStepTimeoutSec});

  factory RunnerThresholds.fromJson(Map<String, dynamic> json) {
    return RunnerThresholds(
      autoStepTimeoutSec: json['auto_step_timeout_sec'] ?? 8,
    );
  }

  /// Lấy Duration từ timeout
  Duration get autoStepTimeout => Duration(seconds: autoStepTimeoutSec);
}
