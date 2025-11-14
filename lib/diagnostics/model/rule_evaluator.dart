import 'dart:convert';
import 'package:flutter/services.dart';
import 'device_profile.dart';
import 'diag_thresholds.dart';
import 'diag_environment.dart';

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
    final thresholdsJson = await rootBundle.loadString(
      'assets/diag_thresholds.json',
    );
    final thresholdsData = json.decode(thresholdsJson);
    final thresholds = DiagThresholds.fromJson(thresholdsData);

    // Load rules
    final rulesJson = await rootBundle.loadString('assets/diag_rules.json');
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
    print('      [RuleEval] Evaluating: $code');
    print('      [RuleEval] Payload: $payload');

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
      case 'gps':
        result = _evalGps(payload);
        break;
      case 'lock':
        result = _evalLock(payload);
        break;
      case 'spen':
        result = _evalSPen(payload);
        break;
      case 'bio':
        result = _evalBio(payload);
        break;
      case 'vibrate':
        result = _evalVibrate(payload);
        break;
      case 'keys':
        result = _evalKeys(payload);
        break;
      case 'touch':
        result = _evalTouch(payload);
        break;
      case 'screen':
        result = _evalScreen(payload);
        break;
      case 'camera':
        result = _evalCamera(payload);
        break;
      case 'speaker':
        result = _evalSpeaker(payload);
        break;
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

    print(
      '      [RuleEval] Result: ${result.toString().split('.').last.toUpperCase()}',
    );
    return result;
  }

  /// Helper: classify radio generation
  int _radioGeneration(String? radio) {
    if (radio == null || radio.isEmpty) return 0; // unknown
    final r = radio.toUpperCase();
    // 2G technologies
    if (r.contains('GPRS') ||
        r.contains('EDGE') ||
        r.contains('GSM') ||
        r.contains('CDMA') ||
        r.contains('1X'))
      return 2;
    // 3G technologies
    if (r.contains('UMTS') ||
        r.contains('HSPA') ||
        r.contains('HSDPA') ||
        r.contains('HSUPA') ||
        r.contains('HSPAP') ||
        r.contains('EVDO'))
      return 3;
    // 4G technologies
    if (r.contains('LTE') || r.contains('WIMAX')) return 4;
    // 5G
    if (r.contains('NR') || r.contains('5G')) return 5;
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
          if (payload['platform'] == 'android' && sdk is int && sdk < 21) {
            return 'Không hỗ trợ thu mua (Android <5)';
          }
          return 'Không đọc được thông tin thiết bị';
        }
        return 'Đọc được thông tin thiết bị';

      case 'battery':
        final level = payload['level'];
        if (result == EvalResult.fail) {
          return 'Mức pin không hợp lệ: $level';
        }
        return 'Mức pin: $level%';

      case 'mobile':
        if (result == EvalResult.skip) {
          if (environment.isPermDenied('phone_state')) {
            return 'Thiếu quyền READ_PHONE_STATE';
          }
          return 'Không kết nối mạng di động';
        }
        final dbm = payload['dbm'];
        final radio = payload['radio'];
        final gen = _radioGeneration(radio is String ? radio : null);
        if (result == EvalResult.fail) {
          if (gen != 0 && gen < 3) {
            return 'Không hỗ trợ thu mua (mạng <3G: $radio)';
          }
          return 'Tín hiệu yếu: $dbm dBm';
        }
        return 'Tín hiệu: $dbm dBm • Radio: $radio';

      case 'wifi':
        if (result == EvalResult.skip) {
          if (!environment.locationServiceOn) {
            return 'Vị trí chưa bật (cần cho SSID)';
          }
          return 'Không kết nối Wi-Fi';
        }
        final ssid = payload['ssid'];
        if (result == EvalResult.fail) {
          return 'Không đọc được SSID';
        }
        return 'Kết nối: $ssid';

      case 'bt':
        if (result == EvalResult.skip) {
          if (environment.isPermDenied('bluetoothScan')) {
            return 'Thiếu quyền Bluetooth';
          }
          if (environment.isMiui && !environment.locationServiceOn) {
            return 'MIUI: cần bật Vị trí để scan BT';
          }
          return 'Bluetooth tắt';
        }
        if (result == EvalResult.fail) {
          return 'Bluetooth bật nhưng không scan được';
        }
        return 'Bluetooth hoạt động';

      case 'nfc':
        if (result == EvalResult.skip) {
          return 'Thiết bị không yêu cầu NFC';
        }
        if (result == EvalResult.fail) {
          return 'Thiết bị yêu cầu NFC nhưng không có';
        }
        return 'NFC khả dụng';

      case 'gps':
        if (result == EvalResult.skip) {
          if (!environment.locationServiceOn) {
            return 'Dịch vụ vị trí chưa bật';
          }
          if (environment.isPermDenied('location')) {
            return 'Thiếu quyền vị trí';
          }
          return 'GPS bị tắt';
        }
        final acc = payload['accuracyM'];
        if (result == EvalResult.fail) {
          return 'Độ chính xác kém: ${acc}m';
        }
        return 'Độ chính xác: ${acc}m';

      case 'spen':
        if (result == EvalResult.skip) {
          return 'Thiết bị không có S-Pen';
        }
        if (result == EvalResult.fail) {
          return 'Thiết bị yêu cầu S-Pen nhưng không phát hiện';
        }
        return 'S-Pen hoạt động';

      case 'touch':
        final ratio = payload['passRatio'] ?? 0.0;
        final deadZones = payload['deadZones'] as List?;
        if (result == EvalResult.fail) {
          if (deadZones != null && deadZones.isNotEmpty) {
            return 'Phát hiện ${deadZones.length} vùng chết';
          }
          return 'Tỷ lệ đạt: ${(ratio * 100).toStringAsFixed(1)}%';
        }
        return 'Màn hình cảm ứng tốt';

      case 'screen':
        if (result == EvalResult.fail) {
          return 'Phát hiện sọc ám/vết cháy màn hình';
        }
        return 'Màn hình không có sọc ám';

      case 'camera':
        if (result == EvalResult.skip) {
          return 'Thiếu quyền camera';
        }
        final photos = payload['photos'] as List?;
        if (result == EvalResult.fail) {
          return 'Không chụp được ảnh';
        }
        return 'Đã chụp ${photos?.length ?? 0} ảnh';

      default:
        return result == EvalResult.pass
            ? 'Đạt'
            : result == EvalResult.fail
            ? 'Lỗi'
            : 'Bỏ qua';
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
      if (sdk is int && sdk < 21) {
        return EvalResult.fail;
      }
    }
    return EvalResult.pass;
  }

  EvalResult _evalBattery(Map<String, dynamic> p) {
    final level = p['level'];
    if (level is! num) return EvalResult.fail;
    if (level < 0 || level > 100) return EvalResult.fail;
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
    if (dbm == null) return EvalResult.fail;
    if (dbm is! num) return EvalResult.fail;

    if (dbm < thresholds.mobile.dbmMin || dbm > thresholds.mobile.dbmMax) {
      return EvalResult.fail;
    }
    // Generation check: Fail if radio tech below 3G
    final radio = p['radio'];
    final gen = _radioGeneration(radio is String ? radio : null);
    if (gen != 0 && gen < 3) {
      return EvalResult.fail;
    }
    return EvalResult.pass;
  }

  EvalResult _evalWifi(Map<String, dynamic> p) {
    final connected = p['connected'] == true;
    if (!connected) return EvalResult.skip;
    if (!environment.locationServiceOn) return EvalResult.skip;

    final ssid = p['ssid'];
    if (ssid == null || ssid == '') return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalBluetooth(Map<String, dynamic> p) {
    if (environment.isPermDenied('bluetoothScan')) return EvalResult.skip;
    if (environment.isMiui && !environment.locationServiceOn)
      return EvalResult.skip;

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
    if (!accel && !environment.hasSensor('accelerometer'))
      return EvalResult.skip;
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
    if (acc == null) return EvalResult.fail;
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

    final detected = p == true || p['detected'] == true;
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
        print('      ⚠️ CRITICAL: Màn hình trong có lỗi → Loại 5');
        return EvalResult.fail;
      }

      // Chỉ có lỗi màn hình ngoài → Đánh giá mức độ
      final severity = _getOuterScreenSeverity(defects);
      if (severity == 'severe') {
        return EvalResult.fail; // Vỡ nặng
      } else if (severity == 'moderate') {
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

  EvalResult _evalRam(Map<String, dynamic> p) {
    final total = p['totalBytes'];
    if (total == null || total == 0) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalRom(Map<String, dynamic> p) {
    final total = p['totalBytes'];
    final free = p['freeBytes'];
    if (total == null || total == 0) return EvalResult.fail;
    if (free == null) return EvalResult.fail;
    return EvalResult.pass;
  }

  EvalResult _evalWired(Map<String, dynamic> p) {
    // Most modern phones don't have headphone jack
    // This is informational only, always pass
    return EvalResult.pass;
  }

  /// Kiểm tra có lỗi màn hình trong không
  bool _hasInnerScreenDefect(List defects) {
    final innerScreenDefects = [
      'Dead pixel',
      'Dead Pixel',
      'Bright pixel',
      'Bright Pixel',
      'Chảy mực',
      'Burn-in',
      'Vết ám',
      'Color Banding',
      'Nhấp nháy',
      'Flickering',
    ];

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

      if (combined.contains('vỡ') || combined.contains('shattered')) {
        hasShattered = true;
      } else if (combined.contains('nứt') || combined.contains('crack')) {
        crackCount++;
      } else if (combined.contains('xước') || combined.contains('scratch')) {
        scratchCount++;
      }
    }

    // Vỡ → Severe
    if (hasShattered) return 'severe';

    // Nhiều vết nứt → Severe
    if (crackCount >= 3) return 'severe';

    // Vài vết nứt hoặc nhiều xước → Moderate
    if (crackCount >= 1 || scratchCount >= 10) return 'moderate';

    // Ít xước → Minor
    if (scratchCount >= 1) return 'minor';

    return 'none';
  }
}
