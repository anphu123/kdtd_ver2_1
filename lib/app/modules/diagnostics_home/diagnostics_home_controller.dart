import 'dart:io';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import 'package:kdtd_ver2_1/app/data/model/device_profile.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_environment.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/services/profile_manager.dart';
import 'package:kdtd_ver2_1/app/data/services/rule_evaluator.dart';
import 'package:kdtd_ver2_1/app/data/services/permission_precheck_service.dart';
import 'package:kdtd_ver2_1/app/data/services/phone_info_service.dart';
import 'package:kdtd_ver2_1/app/data/services/device_info_helper.dart';
import 'package:kdtd_ver2_1/app/data/services/device_name_mapper.dart';
import 'package:kdtd_ver2_1/app/data/services/diag_logger.dart';
import 'package:kdtd_ver2_1/app/modules/camera_test/camera_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/camera_test/camera_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/earpiece_test/earpiece_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/earpiece_test/earpiece_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/failed_tests_warning/failed_tests_warning_page.dart';
import 'package:kdtd_ver2_1/app/modules/keys_test/keys_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/keys_test/keys_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/mic_test/mic_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/mic_test/mic_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/screen_defect_detection/screen_defect_detection_binding.dart';
import 'package:kdtd_ver2_1/app/modules/screen_defect_detection/screen_defect_detection_page.dart';
import 'package:kdtd_ver2_1/app/modules/speaker_test/speaker_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/speaker_test/speaker_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/touch_grid_test/touch_grid_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/touch_grid_test/touch_grid_test_page.dart';

const _channel = MethodChannel('com.fidobox/diagnostics');

Future<T?> _invoke<T>(String method, [dynamic arguments]) async {
  try {
    return await _channel.invokeMethod<T>(method, arguments);
  } catch (_) {
    return null;
  }
}

/// ============================================================
/// DiagnosticsHomeController - Điều Phối Toàn Bộ Quy Trình Kiểm Định
/// ============================================================
///
/// Bản GetX của module: mỗi màn hình có Controller + Binding riêng
/// (`lib/diagnostics/controllers` + `lib/diagnostics/bindings`), điều
/// hướng qua `Get.to`, dialog/snackbar qua `Get.dialog`/`Get.snackbar` —
/// không cần lớp trung gian kiểu `AppNavigator` vì GetX tự có
/// `Get.context`/`Get.key` nội bộ.
class DiagnosticsHomeController extends GetxController {
  // ==================== DEVICE INFO (derived) ====================
  Map<String, dynamic>? get _osModel => info['osmodel'] as Map<String, dynamic>?;

  bool get isAndroid => _osModel?['platform'] == 'android';
  bool get isIOS => _osModel?['platform'] == 'ios';
  String get platform => (_osModel?['platform'] as String?) ?? 'unknown';
  String get vendor => (_osModel?['vendor'] as String?) ?? '';
  String get brand => (_osModel?['brand'] as String?) ?? '';
  String get manufacturer => (_osModel?['manufacturer'] as String?) ?? '';
  String get modelName => (_osModel?['model'] as String?) ?? '';
  String get marketingName => (_osModel?['marketingName'] as String?) ?? '';
  String get origin => (_osModel?['origin'] as String?) ?? 'Không xác định';
  bool get isSamsung => vendor.toLowerCase() == 'samsung';
  bool get isApple => vendor.toLowerCase() == 'apple' || isIOS;

  // ==================== REACTIVE STATE ====================
  final steps = <DiagStep>[].obs;
  final isRunning = false.obs;
  final passedCount = 0.obs;
  final failedCount = 0.obs;
  final skippedCount = 0.obs;
  final info = <String, dynamic>{}.obs;

  /// Phase (nhóm test) hiện đang chạy song song.
  final currentPhase = Rx<DiagPhase>(DiagPhase.critical);
  final phaseProgress = 0.obs;
  final phaseTotal = 0.obs;

  int get total => steps.length;
  int get completed => passedCount.value + failedCount.value + skippedCount.value;
  int get score => total > 0 ? (passedCount.value * 100 / total).round() : 0;
  String get grade {
    if (score >= 90) return 'Loại 1 (Xuất sắc)';
    if (score >= 75) return 'Loại 2 (Tốt)';
    if (score >= 60) return 'Loại 3 (Khá)';
    if (score >= 40) return 'Loại 4 (Trung bình)';
    return 'Loại 5 (Cần cải thiện)';
  }

  RuleEvaluator? _evaluator;
  DeviceProfile? profile;
  DiagEnvironment _environment = const DiagEnvironment();

  final _battery = Battery();
  final _deviceInfo = DeviceInfoPlugin();
  List<CameraDescription> _cams = [];
  DateTime? _startTime;

  @override
  void onInit() {
    super.onInit();
    steps.assignAll(_buildSteps());
    _prepareCameras();
    _startInitialization();
  }

  // ==================== INITIALIZATION ====================

  Future<void> _startInitialization() async {
    DiagLogger.log('Starting initialization sequence...');
    await _collectDeviceInfoSafe();
    await _initializeEvaluator();
  }

  Future<void> _collectDeviceInfoSafe() async {
    try {
      final osInfo = await _getOsAndModel();
      info['osmodel'] = osInfo;
      DiagLogger.log('Identified: ${osInfo['brand']} - ${osInfo['model']} (${osInfo['platform']})');

      try {
        final results = await Future.wait<Map<String, dynamic>>([
          _getBatteryInfo(),
          _getWifiInfo(),
          _getRamInfo(),
          _getRomInfo(),
        ]);
        info['battery'] = results[0];
        info['wifi'] = results[1];
        info['ram'] = results[2];
        info['rom'] = results[3];
      } catch (e) {
        DiagLogger.warning('init', 'Lỗi thu thập thông tin phụ: $e');
      }
    } catch (e, stack) {
      DiagLogger.error('init', 'Lỗi nghiêm trọng khi thu thập thông tin thiết bị: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _initializeEvaluator() async {
    try {
      final osInfo = info['osmodel'] as Map<String, dynamic>? ?? {};
      final deviceBrand = osInfo['brand'] as String? ?? '';
      final deviceModel = osInfo['model'] as String? ?? '';

      final profileManager = await ProfileManager.getInstance();
      profile = profileManager.getProfile(deviceModel, deviceBrand);
      DiagLogger.log('Profile loaded: ${profile?.name ?? "default"} (tier ${profile?.tier})');

      await _updateEnvironment();
      _evaluator = await RuleEvaluator.create(profile: profile!, environment: _environment);
      DiagLogger.log('Rule evaluator initialized successfully');
    } catch (e) {
      DiagLogger.error('init', 'Failed to initialize evaluator: $e. Using default profile as fallback.');
      profile = const DeviceProfile(name: 'default');
    }
  }

  Future<void> _updateEnvironment() async {
    final deniedPerms = <String>{};
    final grantedPerms = <String>{};

    final permsToCheck = {
      'location': Permission.location,
      'camera': Permission.camera,
      'microphone': Permission.microphone,
      'phone_state': Permission.phone,
      'bluetoothScan': Permission.bluetoothScan,
    };

    for (final entry in permsToCheck.entries) {
      final status = await entry.value.status;
      if (status.isGranted) {
        grantedPerms.add(entry.key);
      } else {
        deniedPerms.add(entry.key);
      }
    }

    bool locationOn = false;
    try {
      locationOn = await Geolocator.isLocationServiceEnabled();
    } catch (_) {}

    final sensorInfo = info['sensors'] as Map<String, dynamic>? ?? {};

    _environment = DiagEnvironment(
      brand: brand,
      platform: platform,
      locationServiceOn: locationOn,
      deniedPerms: deniedPerms,
      grantedPerms: grantedPerms,
      sensors: {
        'accelerometer': sensorInfo['accelerometer'] == true,
        'gyroscope': sensorInfo['gyroscope'] == true,
      },
    );
  }

  List<DiagStep> _buildSteps() {
    return [
      // ========== PHASE 1: CRITICAL INFO (song song) ==========
      DiagStep(
        code: 'osmodel',
        title: 'OS/Model',
        kind: DiagKind.auto,
        phase: DiagPhase.critical,
        timeout: const Duration(seconds: 5),
        run: _snapOsModel,
      ),
      DiagStep(
        code: 'battery',
        title: 'Pin & Sạc',
        kind: DiagKind.auto,
        phase: DiagPhase.critical,
        timeout: const Duration(seconds: 3),
        run: _snapBattery,
      ),
      DiagStep(
        code: 'ram',
        title: 'RAM (free/total)',
        kind: DiagKind.auto,
        phase: DiagPhase.critical,
        timeout: const Duration(seconds: 3),
        run: _snapRam,
      ),
      DiagStep(
        code: 'rom',
        title: 'ROM (free/total)',
        kind: DiagKind.auto,
        phase: DiagPhase.critical,
        timeout: const Duration(seconds: 3),
        run: _snapRom,
      ),

      // ========== PHASE 2: CONNECTIVITY (song song) ==========
      DiagStep(
        code: 'wifi',
        title: 'Wi-Fi (SSID)',
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 5),
        run: _snapWifi,
      ),
      DiagStep(
        code: 'mobile',
        title: 'Mạng di động (radio, dBm)',
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 5),
        run: _snapMobile,
      ),
      DiagStep(
        code: 'bt',
        title: 'Bluetooth (scan)',
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 5),
        run: _checkBluetooth,
      ),
      DiagStep(
        code: 'nfc',
        title: 'NFC',
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 3),
        run: _snapNfc,
      ),

      // ========== PHASE 3: SENSORS (song song) ==========
      DiagStep(
        code: 'sensors',
        title: 'Cảm biến (accel/gyro)',
        kind: DiagKind.auto,
        phase: DiagPhase.sensors,
        timeout: const Duration(seconds: 3),
        run: _snapSensors,
      ),
      DiagStep(
        code: 'gps',
        title: 'GPS (accuracy)',
        kind: DiagKind.auto,
        phase: DiagPhase.sensors,
        timeout: const Duration(seconds: 10),
        run: _snapGps,
      ),
      DiagStep(
        code: 'bio',
        title: 'Sinh trắc (khả dụng)',
        kind: DiagKind.auto,
        phase: DiagPhase.sensors,
        timeout: const Duration(seconds: 3),
        run: _snapBiometrics,
      ),

      // ========== PHASE 4: HARDWARE AUTO (song song) ==========
      DiagStep(
        code: 'charge',
        title: 'Nguồn sạc (USB/AC/Wireless)',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 3),
        run: _snapCharging,
      ),
      DiagStep(
        code: 'sim',
        title: 'SIM (slot/trạng thái)',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 3),
        run: _snapSim,
      ),
      DiagStep(
        code: 'wired',
        title: 'Tai nghe có dây',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 2),
        run: _snapWiredHeadset,
      ),
      DiagStep(
        code: 'lock',
        title: 'Màn hình khoá',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 2),
        run: _snapScreenLock,
      ),
      DiagStep(
        code: 'spen',
        title: 'S-Pen (Samsung)',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 2),
        run: _snapSPen,
      ),
      DiagStep(
        code: 'vibrate',
        title: 'Rung',
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 10),
        run: _testVibration,
      ),

      // ========== PHASE 5: SCREEN (tự động) ==========
      DiagStep(
        code: 'screen',
        title: 'Màn hình (Tự động phát hiện lỗi)',
        kind: DiagKind.auto,
        phase: DiagPhase.screen,
        timeout: const Duration(seconds: 30),
        run: _testScreenAuto,
      ),

      // ========== PHASE 6: MANUAL TESTS (tuần tự) ==========
      DiagStep(
        code: 'keys',
        title: 'Phím vật lý (xác nhận)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        interact: _openKeysTest,
      ),
      DiagStep(
        code: 'touch',
        title: 'Cảm ứng full màn',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        interact: _openTouchGrid,
      ),
      DiagStep(
        code: 'camera',
        title: 'Camera trước/sau',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 120),
        interact: _openCameraQuick,
      ),
      DiagStep(
        code: 'speaker',
        title: 'Loa ngoài (beep)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        interact: _openSpeakerTest,
      ),
      DiagStep(
        code: 'mic',
        title: 'Micro (amplitude)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        interact: _openMicTest,
      ),
      DiagStep(
        code: 'ear',
        title: 'Loa trong (proximity)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        interact: _openEarpieceTest,
      ),
    ];
  }

  Future<void> _prepareCameras() async {
    try {
      _cams = await availableCameras();
      final front = _cams.where((c) => c.lensDirection == CameraLensDirection.front).toList();
      final back = _cams.where((c) => c.lensDirection == CameraLensDirection.back).toList();

      info['camera_specs'] = {
        'total': _cams.length,
        'front': front.length,
        'back': back.length,
        'cameras': _cams
            .map((c) => {
                  'name': c.name,
                  'direction': c.lensDirection.toString().split('.').last,
                  'sensorOrientation': c.sensorOrientation,
                })
            .toList(),
      };
    } catch (_) {
      info['camera_specs'] = {'total': 0, 'front': 0, 'back': 0, 'cameras': []};
    }
  }

  // ==================== RUN FLOW ====================

  /// Xin quyền (có giải thích) rồi mới bắt đầu kiểm định.
  Future<void> startWithPermissionCheck() async {
    if (isRunning.value) return;

    final permissionsGranted = await PermissionPrecheckService.requestPermissionsWithExplanation();
    if (!permissionsGranted) {
      DiagLogger.warning('permission', 'Người dùng từ chối cấp quyền bắt buộc');
      return;
    }

    await start();
  }

  Future<void> start() async {
    if (isRunning.value) return;

    passedCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;
    _startTime = DateTime.now();
    for (final step in steps) {
      step.reset();
    }
    steps.refresh();
    isRunning.value = true;

    if (_evaluator == null) {
      await _initializeEvaluator();
    }
    await _updateEnvironment();

    await _runPhase(DiagPhase.critical);
    await _runPhase(DiagPhase.connectivity);
    await _runPhase(DiagPhase.sensors);
    await _runPhase(DiagPhase.hardware);
    await _runPhase(DiagPhase.screen);
    await _runPhase(DiagPhase.manual);

    isRunning.value = false;
    final totalDuration = DateTime.now().difference(_startTime!);

    DiagLogger.summary(
      total: total,
      passed: passedCount.value,
      failed: failedCount.value,
      skipped: skippedCount.value,
      score: score,
      grade: grade,
      totalDuration: totalDuration,
    );

    _navigateToResult();
  }

  void _navigateToResult() {
    if (score < 70 && failedCount.value > 0) {
      final failedSteps = steps.where((s) => s.status == DiagStatus.failed).toList();
      Get.to(() => FailedTestsWarningPage(failedSteps: failedSteps, score: score));
    } else {
      Get.to(() => const DiagnosticResultPage());
    }
  }

  Future<bool> _runStepWithTimeout(DiagStep step) async {
    final stopwatch = Stopwatch()..start();
    try {
      bool result;
      if (step.kind == DiagKind.auto && step.run != null) {
        result = await step.run!().timeout(
              step.timeout,
              onTimeout: () {
                step.note = 'Timeout sau ${step.timeout.inSeconds}s';
                return false;
              },
            );
      } else if (step.kind == DiagKind.manual && step.interact != null) {
        result = await step.interact!();
      } else {
        step.status = DiagStatus.skipped;
        step.note = 'Không có hàm thực thi';
        return false;
      }
      step.executionTime = stopwatch.elapsed;
      return result;
    } catch (e) {
      step.executionTime = stopwatch.elapsed;
      step.note = 'Lỗi: ${e.toString()}';
      return false;
    } finally {
      stopwatch.stop();
    }
  }

  void _evaluateStep(DiagStep step, bool runSuccess) {
    if (_evaluator != null && info[step.code] != null) {
      final payload = info[step.code] is Map
          ? (info[step.code] as Map).cast<String, dynamic>()
          : {'value': info[step.code]};

      final evalResult = _evaluator!.evaluate(step.code, payload);
      final reason = _evaluator!.getReason(step.code, payload, evalResult);

      switch (evalResult) {
        case EvalResult.pass:
          step.status = DiagStatus.passed;
          step.note = reason;
          passedCount.value++;
          break;
        case EvalResult.fail:
          step.status = DiagStatus.failed;
          step.note = reason;
          failedCount.value++;
          break;
        case EvalResult.skip:
          step.status = DiagStatus.skipped;
          step.note = reason;
          skippedCount.value++;
          break;
      }
    } else if (runSuccess) {
      step.status = DiagStatus.passed;
      passedCount.value++;
    } else if (step.note?.contains('Timeout') == true) {
      step.status = DiagStatus.skipped;
      skippedCount.value++;
    } else {
      step.status = DiagStatus.failed;
      failedCount.value++;
    }
  }

  Future<void> _runPhase(DiagPhase phase) async {
    final phaseSteps = steps.where((s) => s.phase == phase).toList();
    if (phaseSteps.isEmpty) return;

    currentPhase.value = phase;
    phaseProgress.value = 0;
    phaseTotal.value = phaseSteps.length;

    for (final step in phaseSteps) {
      step.status = DiagStatus.running;
    }
    steps.refresh();
    DiagLogger.phaseStart(_phaseName(phase), phaseSteps.length);

    Future<void> runOne(DiagStep step) async {
      final result = await _runStepWithTimeout(step);
      _evaluateStep(step, result);
      phaseProgress.value++;
      steps.refresh();
    }

    if (phase == DiagPhase.manual) {
      for (final step in phaseSteps) {
        await runOne(step);
      }
    } else {
      await Future.wait(phaseSteps.map(runOne));
    }

    DiagLogger.phaseComplete(
      _phaseName(phase),
      phaseSteps.where((s) => s.status == DiagStatus.passed).length,
      phaseSteps.where((s) => s.status == DiagStatus.failed).length,
      phaseSteps.where((s) => s.status == DiagStatus.skipped).length,
    );
  }

  String _phaseName(DiagPhase phase) {
    switch (phase) {
      case DiagPhase.critical:
        return 'CRITICAL INFO';
      case DiagPhase.connectivity:
        return 'CONNECTIVITY';
      case DiagPhase.sensors:
        return 'SENSORS';
      case DiagPhase.hardware:
        return 'HARDWARE';
      case DiagPhase.screen:
        return 'SCREEN';
      case DiagPhase.manual:
        return 'MANUAL TESTS';
    }
  }

  // ==================== RESTART A SINGLE STEP ====================

  Future<void> restartStep(DiagStep step) async {
    if (isRunning.value) return;

    step.status = DiagStatus.running;
    step.note = null;
    steps.refresh();

    final result = await _runStepWithTimeout(step);
    _evaluateStep(step, result);
    steps.refresh();
  }

  // ==================== PRINT RESULTS ====================

  void printTestResults() {
    final ram = (info['ram'] as Map?)?.cast<String, dynamic>() ?? {};
    final rom = (info['rom'] as Map?)?.cast<String, dynamic>() ?? {};

    DiagLogger.log('THIẾT BỊ: ${marketingName.isNotEmpty ? marketingName : modelName} '
        '(${brand.isNotEmpty ? brand : manufacturer}) • $platform');
    DiagLogger.log('RAM: ${_toGiB(ram['totalBytes']) ?? 'N/A'} GB • ROM: ${_toGiB(rom['totalBytes']) ?? 'N/A'} GB');

    for (final step in steps) {
      final tag = step.status.name.toUpperCase();
      DiagLogger.log('[$tag] ${step.title}${step.note != null ? ' — ${step.note}' : ''}');
    }

    DiagLogger.summary(
      total: total,
      passed: passedCount.value,
      failed: failedCount.value,
      skipped: skippedCount.value,
      score: score,
      grade: grade,
      totalDuration: _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero,
    );
  }

  int? _toGiB(dynamic v) {
    if (v is! num) return null;
    const giB = 1024 * 1024 * 1024;
    final gb = v.toDouble() / giB;
    const standardSizes = [2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512, 1024];
    var closest = standardSizes.first;
    var minDiff = (gb - closest).abs();
    for (final size in standardSizes) {
      final diff = (gb - size).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }
    return closest;
  }

  // ==================== INFO / SNAPSHOTS ====================

  Future<bool> _snapBattery() async {
    info['battery'] = await _getBatteryInfo();
    return true;
  }

  Future<bool> _snapOsModel() async {
    info['osmodel'] = await _getOsAndModel();
    final osInfo = info['osmodel'] as Map<String, dynamic>;
    final platform = osInfo['platform'] as String?;
    final sdkInt = osInfo['sdk'] as int?;

    if (platform == 'android') {
      final meetsRequirement = sdkInt != null && sdkInt >= 21; // Android 5.0
      DiagLogger.info('osmodel', meetsRequirement
          ? 'Android ${osInfo['release']} (API $sdkInt) — đạt yêu cầu'
          : 'Android SDK $sdkInt — KHÔNG đạt yêu cầu (cần API 21+)');
    } else if (platform == 'ios') {
      final systemVersion = osInfo['systemVersion'] as String?;
      final major = int.tryParse((systemVersion ?? '').split('.').first);
      final meetsRequirement = major != null && major >= 10;
      DiagLogger.info('osmodel', meetsRequirement
          ? 'iOS $systemVersion — đạt yêu cầu'
          : 'iOS $systemVersion — KHÔNG đạt yêu cầu (cần iOS 10+)');
    }
    return true;
  }

  Future<bool> _snapMobile() async {
    final phonePermission = await Permission.phone.status;
    if (!phonePermission.isGranted) {
      final result = await Permission.phone.request();
      if (!result.isGranted) {
        if (result.isPermanentlyDenied) await openAppSettings();
        DiagLogger.warning('mobile', 'Không có quyền READ_PHONE_STATE');
        return false;
      }
    }

    info['mobile'] = await _getMobileNetworkInfo();
    final mobileInfo = info['mobile'] as Map<String, dynamic>;
    final connected = mobileInfo['connected'] as bool? ?? false;
    final radio = mobileInfo['radio'] as String?;
    return connected && radio != null && _is3GOrHigher(radio);
  }

  bool _is3GOrHigher(String radio) {
    const radio3GOrHigher = ['HSPA', 'HSDPA', 'HSUPA', 'HSPAP', 'LTE', 'NR'];
    return radio3GOrHigher.contains(radio.toUpperCase());
  }

  Future<bool> _snapWifi() async {
    info['wifi'] = await _getWifiInfo();
    final wifiInfo = info['wifi'] as Map<String, dynamic>;
    return (wifiInfo['enabled'] as bool? ?? false) && (wifiInfo['connected'] as bool? ?? false);
  }

  Future<bool> _snapRam() async {
    info['ram'] = await _getRamInfo();
    return true;
  }

  Future<bool> _snapRom() async {
    info['rom'] = await _getRomInfo();
    return true;
  }

  Future<bool> _checkBluetooth() async {
    info['bluetooth'] = await _getBluetoothInfo();
    return true;
  }

  Future<bool> _snapNfc() async {
    info['nfc'] = await _getNfcInfo();
    return true;
  }

  Future<bool> _snapSim() async {
    info['sim'] = await _getSimInfo();
    return true;
  }

  Future<bool> _snapSensors() async {
    info['sensors'] = await _getSensorsPing();
    return true;
  }

  Future<bool> _snapGps() async {
    info['gps'] = await _getLocationAccuracy();
    return true;
  }

  Future<bool> _snapCharging() async {
    info['charge'] = await _getChargingInfo();
    return true;
  }

  Future<bool> _snapWiredHeadset() async {
    info['wired'] = await _isWiredHeadsetPlugged();
    return true;
  }

  Future<bool> _snapScreenLock() async {
    info['lock'] = await _isScreenLocked();
    return true;
  }

  Future<bool> _snapSPen() async {
    info['spen'] = await _isSPenSupported();
    return true;
  }

  Future<bool> _snapBiometrics() async {
    info['bio'] = await _checkBiometrics();
    return true;
  }

  // ---- implementation details (native calls) ----

  Future<Map<String, dynamic>> _getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return {'level': level, 'state': state.name};
  }

  String _getOriginCountry(String brand, String manufacturer) {
    final b = brand.toLowerCase();
    final m = manufacturer.toLowerCase();
    bool has(String s) => b.contains(s) || m.contains(s);

    if (has('samsung') || has('lg')) return 'Hàn Quốc';
    if (has('xiaomi') ||
        has('oppo') ||
        has('vivo') ||
        has('huawei') ||
        has('oneplus') ||
        has('realme') ||
        has('honor') ||
        has('zte') ||
        has('lenovo') ||
        has('meizu') ||
        has('tcl')) {
      return 'Trung Quốc';
    }
    if (has('apple') || has('google') || has('motorola')) return 'Mỹ';
    if (has('sony') || has('sharp') || has('fujitsu')) return 'Nhật Bản';
    if (has('asus') || has('htc') || has('acer')) return 'Đài Loan';
    if (has('nokia')) return 'Phần Lan';
    return 'Không xác định';
  }

  Future<Map<String, dynamic>> _getOsAndModel() async {
    try {
      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        final vendor = a.manufacturer.toLowerCase();
        final origin = _getOriginCountry(a.brand, a.manufacturer);
        final marketingName = DeviceNameMapper.getMarketingName(a.model, a.brand);

        // Cập nhật marketing name từ API (bất đồng bộ, không chặn luồng chính)
        _fetchMarketingNameFromAPI(a.model, a.brand);

        return {
          'platform': 'android',
          'sdk': a.version.sdkInt,
          'release': a.version.release,
          'model': a.model,
          'marketingName': marketingName,
          'brand': a.brand,
          'manufacturer': a.manufacturer,
          'vendor': vendor,
          'origin': origin,
          'isSamsung': vendor == 'samsung',
          'isApple': false,
        };
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        final machine = i.utsname.machine;
        final friendlyName = await DeviceInfoHelper.getModel();

        return {
          'platform': 'ios',
          'systemVersion': i.systemVersion,
          'model': machine,
          'marketingName': friendlyName,
          'name': i.name,
          'brand': 'Apple',
          'manufacturer': 'Apple',
          'vendor': 'apple',
          'origin': 'Mỹ',
          'isSamsung': false,
          'isApple': true,
        };
      }
      return {'platform': 'unknown', 'origin': 'Không xác định'};
    } catch (e) {
      DiagLogger.error('osmodel', 'Lỗi lấy thông tin OS: $e');
      return {'platform': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _getMobileNetworkInfo() async {
    final conn = await Connectivity().checkConnectivity();
    final onMobile = conn.contains(ConnectivityResult.mobile);
    int? dbm;
    String? radio;
    if (onMobile) {
      final sig = await DeviceInfoHelper.getSignalStrength();
      dbm = sig['dbm'];
      radio = await _invoke<String>('getMobileRadioType');
    }
    return {'connected': onMobile, 'dbm': dbm, 'radio': radio};
  }

  Future<Map<String, dynamic>> _getWifiInfo() async {
    final wifiEnabled = await _invoke<bool>('isWifiEnabled');
    final conn = await Connectivity().checkConnectivity();
    final onWifi = conn.contains(ConnectivityResult.wifi) || conn.contains(ConnectivityResult.ethernet);
    String? ssid;
    if (onWifi) {
      try {
        if (await Permission.locationWhenInUse.request().isGranted) {
          ssid = await NetworkInfo().getWifiName();
        }
      } catch (_) {}
    }
    return {'enabled': wifiEnabled ?? onWifi, 'connected': onWifi, 'ssid': ssid};
  }

  Future<Map<String, dynamic>> _getRamInfo() async {
    try {
      return await DeviceInfoHelper.getRamInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  Future<Map<String, dynamic>> _getRomInfo() async {
    try {
      return await DeviceInfoHelper.getRomInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  Future<Map<String, dynamic>> _getBluetoothInfo() async {
    var btState = FlutterBluePlus.adapterStateNow;
    if (btState != BluetoothAdapterState.on) {
      try {
        btState = await FlutterBluePlus.adapterState.first.timeout(const Duration(milliseconds: 500));
      } catch (_) {}
    }
    bool scanOk = false;
    if (btState == BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
        await Future.delayed(const Duration(seconds: 2));
        await FlutterBluePlus.stopScan();
        scanOk = true;
      } catch (_) {}
    }
    return {'enabled': btState == BluetoothAdapterState.on, 'scanOk': scanOk};
  }

  Future<Map<String, dynamic>> _getNfcInfo() async {
    bool available = false;
    try {
      available = await NfcManager.instance.isAvailable();
    } catch (_) {}
    return {'available': available};
  }

  Future<Map<String, dynamic>> _getSimInfo() => DeviceInfoHelper.getSimInfo();

  Future<Map<String, dynamic>> _getSensorsPing() async {
    bool accel = false, gyro = false;
    try {
      final s = accelerometerEventStream().listen((_) {});
      await Future.delayed(const Duration(milliseconds: 300));
      await s.cancel();
      accel = true;
    } catch (_) {}
    try {
      final s = gyroscopeEventStream().listen((_) {});
      await Future.delayed(const Duration(milliseconds: 300));
      await s.cancel();
      gyro = true;
    } catch (_) {}
    return {'accelerometer': accel, 'gyroscope': gyro};
  }

  Future<Map<String, dynamic>> _getLocationAccuracy() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    final svc = await Geolocator.isLocationServiceEnabled();
    double? accuracy;
    if (svc && (perm == LocationPermission.always || perm == LocationPermission.whileInUse)) {
      try {
        accuracy = (await Geolocator.getCurrentPosition()).accuracy;
      } catch (_) {}
    }
    return {'serviceOn': svc, 'accuracyM': accuracy};
  }

  Future<Map<String, dynamic>> _getChargingInfo() async {
    final state = await _battery.batteryState;
    final src = await _invoke<String>('getChargingSource');
    return {'state': state.name, 'source': src};
  }

  Future<bool?> _isWiredHeadsetPlugged() => _invoke<bool>('isWiredHeadsetPlugged');

  Future<bool?> _isScreenLocked() => _invoke<bool>('isScreenLocked');

  Future<bool> _isSPenSupported() async => (await _invoke<bool>('isSPenSupported')) == true;

  Future<Map<String, dynamic>> _checkBiometrics() async {
    final la = LocalAuthentication();
    bool can = false, supported = false;
    try {
      can = await la.canCheckBiometrics;
      supported = await la.isDeviceSupported();
    } catch (_) {}
    return {'canCheck': can, 'supported': supported};
  }

  // ==================== INTERACTIVE ====================

  Future<bool> _testVibration() async {
    try {
      final hasVibrator = (await Vibration.hasVibrator()) == true;
      if (!hasVibrator) return false;

      final vibrationCount = math.Random().nextInt(3) + 1; // 1..3
      for (var i = 0; i < vibrationCount; i++) {
        await Vibration.vibrate(duration: 300);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final result = await Get.dialog<int>(
        AlertDialog(
          title: const Text('Kiểm tra rung'),
          content: const Text('Máy vừa rung bao nhiêu lần?'),
          actions: [0, 1, 2, 3]
              .map((n) => TextButton(
                    onPressed: () => Get.back(result: n),
                    child: Text(n == 0 ? 'Không rung' : '$n lần'),
                  ))
              .toList(),
        ),
        barrierDismissible: false,
      );

      return result == vibrationCount;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openTouchGrid() async => (await Get.to<bool>(
        () => const TouchGridTestPage(),
        binding: TouchGridTestBinding(),
      )) == true;

  Future<bool> _testScreenAuto() async {
    try {
      final result = await Get.to<Map<String, dynamic>?>(
        () => const ScreenDefectDetectionPage(),
        binding: ScreenDefectDetectionBinding(),
      );
      if (result == null) return false;

      info['screen'] = result;
      final passed = result['passed'] == true;
      final defectCount = result['defectCount'] as int? ?? 0;
      DiagLogger.info('screen', passed ? 'Không có lỗi' : 'Phát hiện $defectCount lỗi màn hình');
      return passed;
    } catch (e) {
      DiagLogger.error('screen', 'Lỗi test màn hình: $e');
      return false;
    }
  }

  Future<bool> _openCameraQuick() async {
    try {
      final st = await [Permission.camera].request();
      if (st[Permission.camera] != PermissionStatus.granted) return false;
      if (_cams.isEmpty) return false;

      final ok = await Get.to<bool>(
        () => const CameraTestPage(),
        binding: CameraTestBinding(),
        arguments: _cams,
      );
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openSpeakerTest() async => (await Get.to<bool>(
        () => const SpeakerTestPage(),
        binding: SpeakerTestBinding(),
      )) == true;

  Future<bool> _openMicTest() async => (await Get.to<bool>(
        () => const MicTestPage(),
        binding: MicTestBinding(),
      )) == true;

  Future<bool> _openEarpieceTest() async => (await Get.to<bool>(
        () => const EarpieceTestPage(),
        binding: EarpieceTestBinding(),
      )) == true;

  Future<bool> _openKeysTest() async {
    final result = await Get.to<Map<String, dynamic>?>(
      () => const KeysTestPage(),
      binding: KeysTestBinding(),
    );
    if (result == null) return false;

    info['keys'] = result;
    return (result['userConfirm'] == true) ||
        (result['volumeUp'] == true && result['volumeDown'] == true);
  }

  // ==================== PHONE INFO API ====================

  Future<void> _fetchMarketingNameFromAPI(String model, String brand) async {
    try {
      final marketingName = await PhoneInfoService.getMarketingName(model, brand);
      if (marketingName != null && marketingName.isNotEmpty && info['osmodel'] != null) {
        (info['osmodel'] as Map)['marketingName'] = marketingName;
        info.refresh();
      }
    } catch (e) {
      DiagLogger.warning('phoneinfo', 'Lỗi lấy marketing name từ API: $e');
    }
  }

  Future<String?> getPhoneImageUrl() async {
    try {
      return await PhoneInfoService.getPhoneImageUrl(modelName, brand);
    } catch (_) {
      return null;
    }
  }

  Future<PhoneInfo?> getPhoneInfo() async {
    try {
      return await PhoneInfoService.getPhoneInfo(modelName, brand);
    } catch (_) {
      return null;
    }
  }
}
