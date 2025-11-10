/// Diagnostic Thresholds - Pass/Fail criteria values
class DiagThresholds {
  final MobileThresholds mobile;
  final GpsThresholds gps;
  final TouchThresholds touch;
  final AudioThresholds audio;
  final RunnerThresholds runner;

  const DiagThresholds({
    required this.mobile,
    required this.gps,
    required this.touch,
    required this.audio,
    required this.runner,
  });

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

  /// Default thresholds
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

class MobileThresholds {
  final int dbmMin;
  final int dbmMax;

  const MobileThresholds({
    required this.dbmMin,
    required this.dbmMax,
  });

  factory MobileThresholds.fromJson(Map<String, dynamic> json) {
    return MobileThresholds(
      dbmMin: json['dbm_min'] ?? -120,
      dbmMax: json['dbm_max'] ?? -40,
    );
  }
}

class GpsThresholds {
  final double accuracyMPass;
  final int timeoutSec;

  const GpsThresholds({
    required this.accuracyMPass,
    required this.timeoutSec,
  });

  factory GpsThresholds.fromJson(Map<String, dynamic> json) {
    return GpsThresholds(
      accuracyMPass: (json['accuracy_m_pass'] ?? 50).toDouble(),
      timeoutSec: json['timeout_sec'] ?? 8,
    );
  }
}

class TouchThresholds {
  final double passRatioMin;

  const TouchThresholds({
    required this.passRatioMin,
  });

  factory TouchThresholds.fromJson(Map<String, dynamic> json) {
    return TouchThresholds(
      passRatioMin: (json['pass_ratio_min'] ?? 0.98).toDouble(),
    );
  }
}

class AudioThresholds {
  final double micRmsMin;

  const AudioThresholds({
    required this.micRmsMin,
  });

  factory AudioThresholds.fromJson(Map<String, dynamic> json) {
    return AudioThresholds(
      micRmsMin: (json['mic_rms_min'] ?? -20).toDouble(),
    );
  }
}

class RunnerThresholds {
  final int autoStepTimeoutSec;

  const RunnerThresholds({
    required this.autoStepTimeoutSec,
  });

  factory RunnerThresholds.fromJson(Map<String, dynamic> json) {
    return RunnerThresholds(
      autoStepTimeoutSec: json['auto_step_timeout_sec'] ?? 8,
    );
  }
}

