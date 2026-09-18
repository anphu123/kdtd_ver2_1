import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/app/core/constants/diagnostics_constants.dart';
import 'package:kdtd_ver2_1/app/core/constants/rule_evaluator_constants.dart';
import 'package:kdtd_ver2_1/gen/assets.gen.dart';
import 'diag_logger.dart';
import '../model/device_profile.dart';
import '../model/diag_thresholds.dart';
import '../model/diag_environment.dart';

import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Result of evaluation
enum EvalResult { pass, fail, skip }

/// Rule Evaluator - Automatically evaluates diagnostic test results
/// Based on rules from assets/diag_rules.json and thresholds
class RuleEvaluator {
  final DiagThresholds thresholds;
  final DeviceProfile profile;
  final DiagEnvironment environment;
  final Map<String, dynamic> _rules = {};

  RuleEvaluator({
    required this.thresholds,
    required this.profile,
    required this.environment,
  });

  /// Load rules from JSON asset
  static Future<RuleEvaluator> create({
    required DeviceProfile profile,
    required DiagEnvironment environment,
  }) async {
    // Load thresholds
    final thresholdsJson = await rootBundle.loadString(Assets.diagThresholds);
    final thresholdsData = json.decode(thresholdsJson);
    final thresholds = DiagThresholds.fromJson(thresholdsData);

    // Load rules
    final rulesJson = await rootBundle.loadString(Assets.diagRules);
    final rules = json.decode(rulesJson) as Map<String, dynamic>;

    final evaluator = RuleEvaluator(
      thresholds: thresholds,
      profile: profile,
      environment: environment,
    );
    evaluator._rules.addAll(rules);

    return evaluator;
  }

  /// Evaluate a diagnostic step
  EvalResult evaluate(String code, Map<String, dynamic> payload) {
    DiagLogger.verbose('[RuleEval] Evaluating: $code');
    DiagLogger.verbose('[RuleEval] Payload: $payload');

    EvalResult result;
    switch (code) {
      case 'osmodel':
        result = _evalOsModel(payload);
        break;
      case 'battery':
        result = _evalBattery(payload);
        break;
      case 'charge':
        result = _evalCharge(payload);
        break;
      case 'mobile':
        result = _evalMobile(payload);
        break;
      case 'wifi':
        result = _evalWifi(payload);
        break;
      case 'bluetooth':
      case 'bt':
        result = _evalBluetooth(payload);
        break;
      case 'nfc':
        result = _evalNfc(payload);
        break;
      case 'sim':
        result = _evalSim(payload);
        break;
      case 'sensors':
        result = _evalSensors(payload);
        break;
      case 'location':
      case 'gps':
        result = _evalGps(payload);
        break;
      case 'lock':
        result = _evalLock(payload);
        break;
      case 'spen':
        result = _evalSPen(payload);
        break;
      case 'biometrics':
      case 'bio':
        result = _evalBio(payload);
        break;
      case 'vibration':
      case 'vibrate':
        result = _evalVibrate(payload);
        break;
      case 'volume-up':
      case 'volume-down':
      case 'keys':
        result = _evalKeys(payload);
        break;
      case 'touch-screen':
      case 'touch':
        result = _evalTouch(payload);
        break;
      case 'screen':
        result = _evalScreen(payload);
        break;
      case 'front-camera':
      case 'rear-camera':
      case 'camera':
        result = _evalCamera(payload);
        break;
      case 'external-speaker':
      case 'speaker':
        result = _evalSpeaker(payload);
        break;
      case 'internal-speaker':
      case 'ear':
        result = _evalEar(payload);
        break;
      case 'mic':
        result = _evalMic(payload);
        break;
      case 'ram':
        result = _evalRam(payload);
        break;
      case 'rom':
        result = _evalRom(payload);
        break;
      case 'wired':
        result = _evalWired(payload);
        break;
      default:
        result = EvalResult.skip; // Unknown test
    }

    DiagLogger.info(
      code,
      '[RuleEval] Result: ${result.toString().split('.').last.toUpperCase()}',
    );
    return result;
  }

  /// Helper: classify radio generation
  int _radioGeneration(String? radio) {
    if (radio == null || radio.isEmpty) return 0; // unknown
    final r = radio.toUpperCase();
    // 2G technologies
    if (RuleEvaluatorConstants.radio2GKeywords.any((k) => r.contains(k))) {
      return 2;
    }
    // 3G technologies
    if (RuleEvaluatorConstants.radio3GKeywords.any((k) => r.contains(k))) {
      return 3;
    }
    // 4G technologies
    if (RuleEvaluatorConstants.radio4GKeywords.any((k) => r.contains(k))) {
      return 4;
    }
    // 5G
    if (RuleEvaluatorConstants.radio5GKeywords.any((k) => r.contains(k))) {
      return 5;
    }
    return 0; // unknown
  }

  /// Get human-readable reason for the result
  String getReason(
    String code,
    Map<String, dynamic> payload,
    EvalResult result,
  ) {
    switch (code) {
      case 'osmodel':
        if (result == EvalResult.fail) {
          final sdk = payload['sdk'];
          if (payload['platform'] == 'android' &&
              sdk is int &&
              sdk < DiagnosticsConstants.minAndroidSdk) {
            return LocaleKeys.rule_evaluator_osmodel_not_supported_android.trans();
          }
          return LocaleKeys.rule_evaluator_osmodel_read_failed.trans();
        }
        return LocaleKeys.rule_evaluator_osmodel_read_success.trans();

      case 'battery':
        final level = payload['level'];
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_battery_invalid_level.trans(
            namedArgs: {'level': '$level'},
          );
        }
        return LocaleKeys.rule_evaluator_battery_level.trans(
          namedArgs: {'level': '$level'},
        );

      case 'mobile':
        if (result == EvalResult.skip) {
          if (environment.isPermDenied('phone_state')) {
            return LocaleKeys.rule_evaluator_mobile_missing_permission.trans();
          }
          return LocaleKeys.rule_evaluator_mobile_not_connected.trans();
        }
        final dbm = payload['dbm'];
        final radio = payload['radio'];
        final gen = _radioGeneration(radio is String ? radio : null);
        if (result == EvalResult.fail) {
          if (gen != 0 && gen < RuleEvaluatorConstants.minAcceptableRadioGeneration) {
            return LocaleKeys.rule_evaluator_mobile_not_supported_radio.trans(
              namedArgs: {'radio': '$radio'},
            );
          }
          return LocaleKeys.rule_evaluator_mobile_weak_signal.trans(
            namedArgs: {'dbm': '$dbm'},
          );
        }
        return LocaleKeys.rule_evaluator_mobile_signal_info.trans(
          namedArgs: {'dbm': '$dbm', 'radio': '$radio'},
        );

      case 'wifi':
        final enabled = payload['enabled'] == true;
        final connected = payload['connected'] == true;
        if (result == EvalResult.fail || result == EvalResult.skip) {
          if (!enabled) {
            return LocaleKeys.rule_evaluator_wifi_cannot_enable.trans();
          }
          return LocaleKeys.rule_evaluator_wifi_not_responding.trans();
        }
        final ssid = payload['ssid'];
        if (connected &&
            ssid != null &&
            ssid != '' &&
            ssid != '<unknown ssid>') {
          return LocaleKeys.rule_evaluator_wifi_connected.trans(
            namedArgs: {'ssid': '$ssid'},
          );
        }
        if (enabled) {
          return LocaleKeys.rule_evaluator_wifi_antenna_good.trans();
        }
        return LocaleKeys.rule_evaluator_wifi_pass.trans();

      case 'bluetooth':
      case 'bt':
        if (result == EvalResult.skip) {
          if (environment.isPermDenied('bluetoothScan')) {
            return LocaleKeys.rule_evaluator_bt_missing_permission.trans();
          }
          if (environment.isMiui && !environment.locationServiceOn) {
            return LocaleKeys.rule_evaluator_bt_miui_location_required.trans();
          }
          return LocaleKeys.rule_evaluator_bt_disabled.trans();
        }
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_bt_scan_failed.trans();
        }
        return LocaleKeys.rule_evaluator_bt_working.trans();

      case 'nfc':
        if (result == EvalResult.skip) {
          return LocaleKeys.rule_evaluator_nfc_not_required.trans();
        }
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_nfc_required_missing.trans();
        }
        return LocaleKeys.rule_evaluator_nfc_available.trans();

      case 'location':
      case 'gps':
        if (result == EvalResult.skip) {
          if (!environment.locationServiceOn) {
            return LocaleKeys.rule_evaluator_gps_location_service_off.trans();
          }
          if (environment.isPermDenied('location')) {
            return LocaleKeys.rule_evaluator_gps_missing_permission.trans();
          }
          return LocaleKeys.rule_evaluator_gps_disabled.trans();
        }
        final acc = payload['accuracyM'];
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_gps_poor_accuracy.trans(
            namedArgs: {'acc': '$acc'},
          );
        }
        return LocaleKeys.rule_evaluator_gps_accuracy.trans(
            namedArgs: {'acc': '$acc'},
        );

      case 'spen':
        if (result == EvalResult.skip) {
          return LocaleKeys.rule_evaluator_spen_not_present.trans();
        }
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_spen_required_missing.trans();
        }
        return LocaleKeys.rule_evaluator_spen_working.trans();

      case 'touch-screen':
      case 'touch':
        final ratio = payload['passRatio'] ?? 0.0;
        final deadZones = payload['deadZones'] as List?;
        if (result == EvalResult.fail) {
          if (deadZones != null && deadZones.isNotEmpty) {
            return LocaleKeys.rule_evaluator_touch_dead_zones.trans(
              namedArgs: {'count': '${deadZones.length}'},
            );
          }
          return LocaleKeys.rule_evaluator_touch_pass_ratio.trans(
            namedArgs: {'ratio': (ratio * 100).toStringAsFixed(1)},
          );
        }
        return LocaleKeys.rule_evaluator_touch_good.trans();

      case 'screen':
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_screen_burn_in_detected.trans();
        }
        return LocaleKeys.rule_evaluator_screen_no_burn_in.trans();

      case 'front-camera':
      case 'rear-camera':
      case 'camera':
        if (result == EvalResult.skip) {
          return LocaleKeys.rule_evaluator_camera_missing_permission.trans();
        }
        final photos = payload['photos'] as List?;
        if (result == EvalResult.fail) {
          return LocaleKeys.rule_evaluator_camera_capture_failed.trans();
        }
        return LocaleKeys.rule_evaluator_camera_photos_captured.trans(
          namedArgs: {'count': '${photos?.length ?? 0}'},
        );

      default:
        return result == EvalResult.pass
            ? LocaleKeys.rule_evaluator_default_pass.trans()
            : result == EvalResult.fail
            ? LocaleKeys.rule_evaluator_default_fail.trans()
            : LocaleKeys.rule_evaluator_default_skip.trans();
    }
  }

  // ==================== Individual Evaluators ====================

  EvalResult _evalOsModel(Map<String, dynamic> p) {
    final platform = p['platform'];
    final model = p['model'];
    if (platform == null ||
        platform == 'unknown' ||
        model == null ||
        model == '') {
      return EvalResult.fail;
    }
    // Auto fail purchase support if Android <5 (API <21)
    if (platform == 'android') {
      final sdk = p['sdk'];
      if (sdk is int && sdk < DiagnosticsConstants.minAndroidSdk) {
        return EvalResult.fail;
      }
    }
    return EvalResult.pass;
  }

  EvalResult _evalBattery(Map<String, dynamic> p) {
    final level = p['level'];
    if (level is! num) return EvalResult.fail;
    if (level < RuleEvaluatorConstants.minBatteryLevel ||
        level > RuleEvaluatorConstants.maxBatteryLevel) {
      return EvalResult.fail;
    }
    return EvalResult.pass;
  }

  EvalResult _evalCharge(Map<String, dynamic> p) {
    final state = p['state'];
    if (state == null) return EvalResult.fail;

    // iOS might not have source
    if (environment.platform == 'ios' && p['source'] == null) {
      return EvalResult.skip;
    }
    return EvalResult.pass;
  }

  EvalResult _evalMobile(Map<String, dynamic> p) {
    final connected = p['connected'] == true;
    if (!connected) return EvalResult.skip;
    if (environment.isPermDenied('phone_state')) return EvalResult.skip;

    final dbm = p['dbm'];
    // iOS (và một số thiết bị Android) trả về null signal strength
    if (dbm == null) return EvalResult.skip;
    if (dbm is! num) return EvalResult.fail;

    if (dbm < thresholds.mobile.dbmMin || dbm > thresholds.mobile.dbmMax) {
      return EvalResult.fail;
    }
    // Generation check: Fail if radio tech below 3G
    final radio = p['radio'];
    final gen = _radioGeneration(radio is String ? radio : null);
    if (gen != 0 && gen < RuleEvaluatorConstants.minAcceptableRadioGeneration) {
      return EvalResult.fail;
    }
    return EvalResult.pass;
  }

  EvalResult _evalWifi(Map<String, dynamic> p) {
    final enabled = p['enabled'] == true;
    final connected = p['connected'] == true;

    // Nếu không bật được ăng-ten Wi-Fi → Không đạt
    if (!enabled && !connected) return EvalResult.fail;

    // Ăng-ten Wi-Fi hoạt động tốt → ĐẠT CHUẨN
    return EvalResult.pass;
  }

  EvalResult _evalBluetooth(Map<String, dynamic> p) {
    if (environment.isPermDenied('bluetoothScan')) return EvalResult.skip;
    if (environment.isMiui && !environment.locationServiceOn) {
      return EvalResult.skip;
    }

    final enabled = p['enabled'] == true;
    if (!enabled) return EvalResult.skip;

    final scanOk = p['scanOk'] == true;
    return scanOk ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalNfc(Map<String, dynamic> p) {
    final available = p['available'] == true;
    final required = profile.requiresFeature('nfc');

    if (!required && !available) return EvalResult.skip;
    if (required && !available) return EvalResult.fail;
    return available ? EvalResult.pass : EvalResult.skip;
  }

  EvalResult _evalSim(Map<String, dynamic> p) {
    if (environment.isPermDenied('phone_state')) return EvalResult.skip;
    // ROM blocks API check could be added here

    final slotCount = p['slotCount'] ?? 0;
    final states = p['states'];

    if (slotCount >= 1 && states != null) return EvalResult.pass;
    // Could check if device should have SIM based on profile
    return EvalResult.skip;
  }

  EvalResult _evalSensors(Map<String, dynamic> p) {
    final accel = p['accelerometer'] == true;
    final gyro = p['gyroscope'] == true;

    // Check if device should have these sensors
    if (!accel && !environment.hasSensor('accelerometer')) {
      return EvalResult.skip;
    }
    if (!gyro && !environment.hasSensor('gyroscope')) return EvalResult.skip;

    if (!accel || !gyro) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalGps(Map<String, dynamic> p) {
    if (!environment.locationServiceOn) return EvalResult.skip;
    if (environment.isPermDenied('location')) return EvalResult.skip;

    final serviceOn = p['serviceOn'] == true;
    if (!serviceOn) return EvalResult.skip;

    final acc = p['accuracyM'];
    if (acc == null) return serviceOn ? EvalResult.pass : EvalResult.skip;
    if (acc is! num) return EvalResult.fail;

    if (acc > thresholds.gps.accuracyMPass) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalLock(Map<String, dynamic> p) {
    final required = profile.secureLock;
    if (!required) return EvalResult.skip;

    final secure = p['secure'] == true;
    return secure ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalSPen(Map<String, dynamic> p) {
    final required = profile.sPen;
    if (!required) return EvalResult.skip;

    final detected = p['detected'] == true;
    return detected ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalBio(Map<String, dynamic> p) {
    // Check if user has set up PIN first
    final canCheck = p['canCheck'] == true;
    if (!canCheck) return EvalResult.skip;

    final required = profile.bio;
    final supported = p['supported'] == true;

    if (!required && !supported) return EvalResult.skip;
    if (required && !supported) return EvalResult.fail;
    return supported ? EvalResult.pass : EvalResult.skip;
  }

  EvalResult _evalVibrate(Map<String, dynamic> p) {
    final confirm = p['userConfirm'] == true;
    return confirm ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalKeys(Map<String, dynamic> p) {
    final confirm = p['userConfirm'] == true;
    return confirm ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalTouch(Map<String, dynamic> p) {
    final ratio = p['passRatio'] ?? 0.0;
    final deadZones = p['deadZones'] as List?;

    if (ratio < thresholds.touch.passRatioMin) return EvalResult.fail;
    if (deadZones != null && deadZones.isNotEmpty) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalScreen(Map<String, dynamic> p) {
    // Kiểm tra kết quả từ auto detection
    final passed = p['passed'] == true;
    final defects = p['defects'] as List? ?? [];
    final defectCount = p['defectCount'] as int? ?? 0;

    // Không có lỗi → Pass
    if (passed && defectCount == 0) {
      return EvalResult.pass;
    }

    // Có lỗi → Phân tích loại lỗi
    if (defectCount > 0) {
      // Kiểm tra xem có lỗi màn hình trong không
      final hasInnerScreenDefect = _hasInnerScreenDefect(defects);

      if (hasInnerScreenDefect) {
        // Màn hình trong có lỗi → FAIL (Loại 5)
        DiagLogger.warning(
          'screen',
          'CRITICAL: Màn hình trong có lỗi → Loại 5',
        );
        return EvalResult.fail;
      }

      // Chỉ có lỗi màn hình ngoài → Đánh giá mức độ
      final severity = _getOuterScreenSeverity(defects);
      if (severity == RuleEvaluatorConstants.screenSeveritySevere) {
        return EvalResult.fail; // Vỡ nặng
      } else if (severity == RuleEvaluatorConstants.screenSeverityModerate) {
        return EvalResult.pass; // Xước vừa - vẫn pass nhưng giảm giá
      } else {
        return EvalResult.pass; // Xước nhẹ
      }
    }

    // Fallback: Manual confirmation (backward compatible)
    final confirm = p['userConfirm'] == true;
    final hasIssue = p['hasIssue'] == true;

    if (hasIssue) return EvalResult.fail;
    if (confirm) return EvalResult.pass;

    // Default: pass if no explicit issue reported
    return EvalResult.pass;
  }

  EvalResult _evalCamera(Map<String, dynamic> p) {
    if (environment.isPermDenied('camera')) return EvalResult.skip;

    final photos = p['photos'] as List?;
    final confirm = p['userConfirm'] == true;

    if (photos == null || photos.isEmpty) return EvalResult.fail;
    if (!confirm) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalSpeaker(Map<String, dynamic> p) {
    final confirm = p['userConfirm'] == true;
    return confirm ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalEar(Map<String, dynamic> p) {
    final confirm = p['userConfirm'] == true;
    return confirm ? EvalResult.pass : EvalResult.fail;
  }

  EvalResult _evalMic(Map<String, dynamic> p) {
    if (environment.isPermDenied('microphone')) return EvalResult.skip;

    final confirm = p['userConfirm'] == true;
    if (!confirm) return EvalResult.fail;

    final rms = p['rms'];
    if (rms != null && rms is num) {
      if (rms < thresholds.audio.micRmsMin) return EvalResult.fail;
    }
    return EvalResult.pass;
  }

  /// Đánh giá RAM
  /// iOS: Có thể chỉ có estimated value → vẫn pass
  EvalResult _evalRam(Map<String, dynamic> p) {
    final source = p['source'] as String?;
    final total = p['totalBytes'];
    final totalGB = p['totalGB'];

    // iOS estimated: vẫn pass vì có ước tính
    if (source == 'ios_estimated' && totalGB != null) {
      return EvalResult.pass;
    }

    // Android: cần có totalBytes
    if (total == null || total == 0) {
      // Nếu là iOS và không đọc được → skip thay vì fail
      if (source?.startsWith('ios') == true) {
        return EvalResult.skip;
      }
      return EvalResult.fail;
    }

    return EvalResult.pass;
  }

  /// Đánh giá ROM/Storage
  /// iOS: Không cho phép đọc chính xác → skip
  EvalResult _evalRom(Map<String, dynamic> p) {
    final source = p['source'] as String?;
    final total = p['totalBytes'];
    final free = p['freeBytes'];

    // iOS: Không cho phép đọc → skip (không phải lỗi phần cứng)
    if (source == 'ios_unavailable') {
      return EvalResult.skip;
    }

    // Android: cần có total
    if (total == null || total == 0) {
      return EvalResult.fail;
    }

    // Kiểm tra dung lượng trống nếu có
    if (free != null && free is num) {
      // Cảnh báo nếu còn ít dung lượng trống (không fail, chỉ log)
      final freeGB = free / RuleEvaluatorConstants.bytesPerGigabyte;
      if (freeGB < RuleEvaluatorConstants.lowFreeStorageWarningGb) {
        // Vẫn pass nhưng note sẽ cảnh báo
      }
    }

    return EvalResult.pass;
  }

  EvalResult _evalWired(Map<String, dynamic> p) {
    // Most modern phones don't have headphone jack
    // This is informational only, always pass
    return EvalResult.pass;
  }

  /// Kiểm tra có lỗi màn hình trong không
  bool _hasInnerScreenDefect(List defects) {
    final innerScreenDefects = RuleEvaluatorConstants.innerScreenDefectKeywords;

    for (var defect in defects) {
      final type = defect['type'] as String? ?? '';
      final description = defect['description'] as String? ?? '';

      // Kiểm tra type hoặc description có chứa keyword màn hình trong
      for (var keyword in innerScreenDefects) {
        if (type.toLowerCase().contains(keyword.toLowerCase()) ||
            description.toLowerCase().contains(keyword.toLowerCase())) {
          return true;
        }
      }
    }

    return false;
  }

  /// Đánh giá mức độ nghiêm trọng của lỗi màn hình ngoài
  String _getOuterScreenSeverity(List defects) {
    int scratchCount = 0;
    int crackCount = 0;
    bool hasShattered = false;

    for (var defect in defects) {
      final type = defect['type'] as String? ?? '';
      final description = defect['description'] as String? ?? '';
      final combined = '$type $description'.toLowerCase();

      if (RuleEvaluatorConstants.shatteredKeywords.any(combined.contains)) {
        hasShattered = true;
      } else if (RuleEvaluatorConstants.crackKeywords.any(combined.contains)) {
        crackCount++;
      } else if (RuleEvaluatorConstants.scratchKeywords.any(
        combined.contains,
      )) {
        scratchCount++;
      }
    }

    // Vỡ → Severe
    if (hasShattered) return RuleEvaluatorConstants.screenSeveritySevere;

    // Nhiều vết nứt → Severe
    if (crackCount >= RuleEvaluatorConstants.severeCrackCountMin) {
      return RuleEvaluatorConstants.screenSeveritySevere;
    }

    // Vài vết nứt hoặc nhiều xước → Moderate
    if (crackCount >= 1 ||
        scratchCount >= RuleEvaluatorConstants.moderateScratchCountMin) {
      return RuleEvaluatorConstants.screenSeverityModerate;
    }

    // Ít xước → Minor
    if (scratchCount >= 1) return RuleEvaluatorConstants.screenSeverityMinor;

    return RuleEvaluatorConstants.screenSeverityNone;
  }
}
