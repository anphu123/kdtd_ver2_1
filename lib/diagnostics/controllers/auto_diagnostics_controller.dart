import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'package:camera/camera.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/diag_step.dart';
import '../model/rule_evaluator.dart';
import '../model/device_profile.dart';
import '../model/diag_environment.dart';
import '../model/profile_manager.dart';
import '../utils/device_name_mapper.dart';
import '../views/advanced_camera_test_page.dart';
import '../views/earpiece_test_page.dart';
import '../views/mic_test_page.dart';
import '../views/speaker_test_page.dart';
import '../views/touch_grid_test_page.dart';
import '../views/screen_burnin_test_page.dart';
import '../views/screen_defect_detection_page.dart';
import '../views/diagnostic_result_page.dart';
import '../views/failed_tests_warning_page.dart';
import '../views/auto_screen_burnin_test_page.dart';
import '../views/keys_test_page.dart';
import '../services/phone_info_service.dart';
import '../services/permission_precheck_service.dart';
import '../utils/device_info_helper.dart';

const _channel = MethodChannel('com.fidobox/diagnostics');

Future<T?> _invoke<T>(String m, [dynamic a]) async {
  try {
    return await _channel.invokeMethod<T>(m, a);
  } catch (_) {
    return null;
  }
}

class AutoDiagnosticsController extends GetxController {
  // Quick helpers for OS/brand checks derived from info['osmodel']
  bool get isAndroid => (info['osmodel']?['platform'] == 'android');

  bool get isIOS => (info['osmodel']?['platform'] == 'ios');

  String get platform => (info['osmodel']?['platform'] as String?) ?? 'unknown';

  String get vendor => (info['osmodel']?['vendor'] as String?) ?? '';

  String get brand => (info['osmodel']?['brand'] as String?) ?? '';

  String get manufacturer =>
      (info['osmodel']?['manufacturer'] as String?) ?? '';

  String get modelName => (info['osmodel']?['model'] as String?) ?? '';

  String get marketingName =>
      (info['osmodel']?['marketingName'] as String?) ?? '';

  String get origin =>
      (info['osmodel']?['origin'] as String?) ?? 'Không xác định';

  bool get isSamsung => vendor.toLowerCase() == 'samsung';

  bool get isApple => vendor.toLowerCase() == 'apple' || isIOS;

  final steps = <DiagStep>[].obs;
  final isRunning = false.obs;
  final passedCount = 0.obs;
  final failedCount = 0.obs;
  final skippedCount = 0.obs;

  // data snapshots để show trong header (pin, os, wifi, ram, rom, ...)
  final info = <String, dynamic>{}.obs;

  // Rule evaluation system
  RuleEvaluator? _evaluator;
  DeviceProfile? _profile;
  DiagEnvironment _environment = const DiagEnvironment();

  // services
  final _battery = Battery();
  final _deviceInfo = DeviceInfoPlugin();
  List<CameraDescription> _cams = [];

  @override
  void onInit() {
    super.onInit();
    steps.assignAll(_buildSteps());
    _prepareCameras();
    _startInitialization();
  }

  /// Khởi tạo tuần tự an toàn
  Future<void> _startInitialization() async {
    print('🚀 Starting initialization sequence...');
    // Bước 1: Thu thập thông tin thiết bị (quan trọng nhất)
    await _collectDeviceInfoSafe();

    // Bước 2: Khởi tạo bộ đánh giá (dựa trên thông tin đã thu thập)
    await _initializeEvaluator();
  }

  /// Thu thập thông tin thiết bị với error handling chi tiết
  Future<void> _collectDeviceInfoSafe() async {
    try {
      print('   ├─ Collecting device info...');

      // Lấy thông tin OS/Model trước (quan trọng để load profile)
      final osInfo = await _getOsAndModel();
      info['osmodel'] = osInfo;
      print(
        '   ├─ Identified: ${osInfo['brand']} - ${osInfo['model']} (${osInfo['platform']})',
      );

      // Lấy các thông tin khác song song
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
        print('   ⚠️ Error collecting secondary info: $e');
        // Vẫn tiếp tục dù lỗi info phụ
      }
    } catch (e, stack) {
      print('   ❌ CRITICAL Error collecting device info: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize the rule evaluator system
  Future<void> _initializeEvaluator() async {
    try {
      print('🔧 Initializing Rule Evaluator...');
      // Info already collected by _collectDeviceInfoSafe

      final osInfo = info['osmodel'] as Map<String, dynamic>? ?? {};
      final deviceBrand = osInfo['brand'] as String? ?? '';
      final deviceModel = osInfo['model'] as String? ?? '';
      print('   ├─ Device Brand: $deviceBrand');
      print('   ├─ Device Model: $deviceModel');
      print('   ├─ Platform: ${osInfo['platform'] ?? 'android'}');
      print('   ├─ Loading ProfileManager...');
      final profileManager = await ProfileManager.getInstance();
      _profile = profileManager.getProfile(deviceModel, deviceBrand);
      print('   ├─ Profile loaded: ${_profile?.name ?? "default"}');
      if (_profile != null) {
        print('   │  ├─ Tier: ${_profile!.tier}');
        print('   │  ├─ S-Pen: ${_profile!.sPen}');
        print('   │  ├─ Biometrics: ${_profile!.bio}');
        print('   │  └─ Auto screen test: ${_profile!.autoScreenTest}');
      }
      print('   ├─ Building environment...');
      await _updateEnvironment();
      print('   ├─ Creating RuleEvaluator...');
      _evaluator = await RuleEvaluator.create(
        profile: _profile!,
        environment: _environment,
      );
      print('   └─ ✅ Rule evaluator initialized successfully!\n');
    } catch (e) {
      print('   └─ ⚠️ Failed to initialize evaluator: $e');
      print('      Using default profile as fallback\n');
      _profile = const DeviceProfile(name: 'default');
    }
  }

  /// Update environment state (permissions, services, etc.)
  Future<void> _updateEnvironment() async {
    final deniedPerms = <String>{};
    final grantedPerms = <String>{};

    // Check key permissions
    final permsToCheck = {
      'location': Permission.location,
      'camera': Permission.camera,
      'microphone': Permission.microphone,
      'phone_state': Permission.phone,
      'bluetoothScan': Permission.bluetoothScan,
    };

    for (var entry in permsToCheck.entries) {
      final status = await entry.value.status;
      if (status.isGranted) {
        grantedPerms.add(entry.key);
      } else {
        deniedPerms.add(entry.key);
      }
    }

    // Check location service
    bool locationOn = false;
    try {
      locationOn = await Geolocator.isLocationServiceEnabled();
    } catch (_) {}

    // Get sensor availability
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
      // ========== PHASE 1: CRITICAL INFO (chạy song song) ==========
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

      // ========== PHASE 2: CONNECTIVITY (chạy song song) ==========
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
        timeout: const Duration(seconds: 5), // Giảm từ mặc định
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

      // ========== PHASE 3: SENSORS (chạy song song với timeout) ==========
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
        timeout: const Duration(seconds: 10), // GPS cần thời gian
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

      // ========== PHASE 4: HARDWARE AUTO (chạy song song) ==========
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
        timeout: const Duration(seconds: 10), // User interaction
        run: _testVibration,
      ),

      // ========== PHASE 5: SCREEN (tự động) ==========
      DiagStep(
        code: 'screen',
        title: 'Màn hình (Tự động phát hiện lỗi)',
        kind: DiagKind.auto,
        phase: DiagPhase.screen,
        timeout: const Duration(seconds: 30), // Screen test cần thời gian
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
        timeout: const Duration(seconds: 120), // Camera test cần thời gian
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

      // Store camera info
      final front =
          _cams
              .where((c) => c.lensDirection == CameraLensDirection.front)
              .toList();
      final back =
          _cams
              .where((c) => c.lensDirection == CameraLensDirection.back)
              .toList();

      final cameraInfo = {
        'total': _cams.length,
        'front': front.length,
        'back': back.length,
        'cameras':
            _cams
                .map(
                  (c) => {
                    'name': c.name,
                    'direction': c.lensDirection.toString().split('.').last,
                    'sensorOrientation': c.sensorOrientation,
                  },
                )
                .toList(),
      };

      info['camera_specs'] = cameraInfo;
    } catch (_) {
      info['camera_specs'] = {'total': 0, 'front': 0, 'back': 0, 'cameras': []};
    }
  }

  // ================== RUN FLOW (OPTIMIZED) ==================

  /// Thời gian bắt đầu test (để tính tổng thời gian)
  DateTime? _startTime;

  /// Current phase đang chạy (để hiển thị trên UI)
  final currentPhase = DiagPhase.critical.obs;

  /// Số step đã hoàn thành trong phase hiện tại
  final phaseProgress = 0.obs;

  /// Tổng số step trong phase hiện tại
  final phaseTotal = 0.obs;

  /// Chạy một step với timeout
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
        // Manual tests không áp dụng timeout cứng
        result = await step.interact!();
      } else {
        step.status = DiagStatus.skipped;
        step.note = 'Không có hàm thực thi';
        return false;
      }

      stopwatch.stop();
      step.executionTime = stopwatch.elapsed;

      return result;
    } catch (e) {
      stopwatch.stop();
      step.executionTime = stopwatch.elapsed;
      step.note = 'Lỗi: ${e.toString()}';
      return false;
    }
  }

  /// Evaluate và cập nhật status cho step
  void _evaluateStep(DiagStep step, bool runSuccess) {
    if (_evaluator != null && info[step.code] != null) {
      final payload =
          info[step.code] is Map
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
    } else {
      // Fallback logic
      if (runSuccess) {
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
  }

  /// Chạy một phase (nhóm các step song song)
  Future<void> _runPhase(DiagPhase phase) async {
    final phaseSteps = steps.where((s) => s.phase == phase).toList();
    if (phaseSteps.isEmpty) return;

    currentPhase.value = phase;
    phaseProgress.value = 0;
    phaseTotal.value = phaseSteps.length;

    final phaseName = _getPhaseName(phase);
    print('\n--- PHASE: $phaseName (${phaseSteps.length} tests) ---');

    // Đánh dấu tất cả step trong phase là running
    for (final step in phaseSteps) {
      step.status = DiagStatus.running;
    }
    steps.refresh();

    if (phase == DiagPhase.manual) {
      // Manual tests chạy tuần tự
      for (final step in phaseSteps) {
        print('  [${step.code}] ${step.title}');
        final result = await _runStepWithTimeout(step);
        _evaluateStep(step, result);
        phaseProgress.value++;
        steps.refresh();

        final statusIcon =
            step.status == DiagStatus.passed
                ? 'PASS'
                : step.status == DiagStatus.failed
                ? 'FAIL'
                : 'SKIP';
        print(
          '     -> $statusIcon (${step.executionTime?.inMilliseconds ?? 0}ms)',
        );
      }
    } else {
      // Auto tests chạy song song
      final futures = phaseSteps.map((step) async {
        print('  [${step.code}] ${step.title}');
        final result = await _runStepWithTimeout(step);
        _evaluateStep(step, result);
        phaseProgress.value++;
        steps.refresh();

        final statusIcon =
            step.status == DiagStatus.passed
                ? 'PASS'
                : step.status == DiagStatus.failed
                ? 'FAIL'
                : 'SKIP';
        print(
          '     -> $statusIcon (${step.executionTime?.inMilliseconds ?? 0}ms)',
        );

        return result;
      });

      await Future.wait(futures);
    }

    // Đếm kết quả phase
    final passed =
        phaseSteps.where((s) => s.status == DiagStatus.passed).length;
    final failed =
        phaseSteps.where((s) => s.status == DiagStatus.failed).length;
    final skipped =
        phaseSteps.where((s) => s.status == DiagStatus.skipped).length;
    print('--- $phaseName DONE: P:$passed F:$failed S:$skipped ---\n');
  }

  /// Lấy tên hiển thị cho phase
  String _getPhaseName(DiagPhase phase) {
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

  /// Bắt đầu kiểm định với việc kiểm tra quyền trước
  /// Đây là method nên được gọi từ UI thay vì start()
  Future<void> startWithPermissionCheck() async {
    if (isRunning.value) return;

    // Yêu cầu quyền với dialog giải thích
    final permissionsGranted =
        await PermissionPrecheckService.requestPermissionsWithExplanation();

    if (!permissionsGranted) {
      // User từ chối quyền bắt buộc
      print('[DIAG] Người dùng từ chối cấp quyền bắt buộc');
      return;
    }

    // Tất cả quyền bắt buộc đã được cấp, bắt đầu test
    await start();
  }

  /// Main start function - OPTIMIZED với parallel execution
  /// Lưu ý: Nên gọi startWithPermissionCheck() thay vì start() trực tiếp
  Future<void> start() async {
    if (isRunning.value) return;

    // Reset state
    isRunning.value = true;
    passedCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;
    _startTime = DateTime.now();

    // Reset all steps
    for (final step in steps) {
      step.reset();
    }
    steps.refresh();

    print('\n========== BAT DAU KIEM DINH (PARALLEL) ==========');
    print('Thoi gian: ${DateTime.now()}\n');

    // Initialize evaluator nếu chưa có
    if (_evaluator == null) {
      print('Khoi tao Rule Evaluator...');
      await _initializeEvaluator();
    }

    if (_evaluator != null) {
      print('Rule Evaluator: ${_profile?.name ?? "default"}');
      print('Platform: $platform | Brand: $brand\n');
    }

    // Update environment
    await _updateEnvironment();

    // Chạy từng phase theo thứ tự
    // Phase 1-4: Auto tests (song song trong mỗi phase)
    await _runPhase(DiagPhase.critical);
    await _runPhase(DiagPhase.connectivity);
    await _runPhase(DiagPhase.sensors);
    await _runPhase(DiagPhase.hardware);
    await _runPhase(DiagPhase.screen);

    // Phase 5: Manual tests (tuần tự)
    await _runPhase(DiagPhase.manual);

    // Kết thúc
    isRunning.value = false;
    final totalDuration = DateTime.now().difference(_startTime!);

    // Tính điểm
    final total = steps.length;
    final score = (passedCount.value * 100 / total).round();
    final grade =
        (score >= 90)
            ? 'Loai 1 (Xuat sac)'
            : (score >= 75)
            ? 'Loai 2 (Tot)'
            : (score >= 60)
            ? 'Loai 3 (Kha)'
            : (score >= 40)
            ? 'Loai 4 (Trung binh)'
            : 'Loai 5 (Can cai thien)';

    // In kết quả
    print('\n========== KET QUA KIEM DINH ==========');
    print('Tong so test:  $total');
    print('Passed:        ${passedCount.value}');
    print('Failed:        ${failedCount.value}');
    print('Skipped:       ${skippedCount.value}');
    print('Diem so:       $score/100');
    print('Xep loai:      $grade');
    print('Thoi gian:     ${totalDuration.inSeconds}s');
    print('==========================================\n');

    // Navigate to result page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        if (score < 70 && failedCount.value > 0) {
          final failedSteps =
              steps.where((s) => s.status == DiagStatus.failed).toList();
          Get.to(
            () =>
                FailedTestsWarningPage(failedSteps: failedSteps, score: score),
          );
        } else {
          Get.to(() => const DiagnosticResultPage());
        }
      }
    });
  }

  // ================== PRINT TEST RESULTS ==================
  /// Prints detailed test results to console
  void printTestResults() {
    print('\n╔═══════════════════════════════════════════════���════════════╗');
    print('║           KẾT QUẢ KIỂM ĐỊNH THIẾT BỊ                      ║');
    print('╚════════════════════════════════════════════════════════════╝\n');

    // Device Information
    print('📱 THÔNG TIN THIẾT BỊ:');
    print(
      '   ├─ Model: ${modelName.isNotEmpty ? modelName : "Không xác định"}',
    );
    print('   ├─ Hãng: ${brand.isNotEmpty ? brand : manufacturer}');
    print('   ├─ Platform: $platform');
    print('   └─ IMEI: ${info["imei"] ?? "N/A"}\n');

    // Hardware Info
    final ram = (info['ram'] as Map?)?.cast<String, dynamic>() ?? {};
    final rom = (info['rom'] as Map?)?.cast<String, dynamic>() ?? {};
    final ramGb = _toGiB(ram['totalBytes']);
    final romGb = _toGiB(rom['totalBytes']);

    print('💾 PHẦN CỨNG:');
    print('   ├─ RAM: ${ramGb != null ? "$ramGb GB" : "N/A"}');
    print('   └─ ROM: ${romGb != null ? "$romGb GB" : "N/A"}\n');

    // Test Results Summary
    final total = steps.length;
    final completed =
        passedCount.value + failedCount.value + skippedCount.value;
    final score = total > 0 ? (passedCount.value * 100 / total).round() : 0;
    final grade = _calculateGrade(score);

    print('📊 TỔNG KẾT:');
    print('   ├─ Tổng số test: $total');
    print('   ├─ Đã thực hiện: $completed');
    print('   ├─ ✓ Passed: ${passedCount.value}');
    print('   ├─ ✗ Failed: ${failedCount.value}');
    print('   ├─ ○ Skipped: ${skippedCount.value}');
    print('   ├─ Điểm số: $score/100');
    print('   └─ Xếp loại: $grade\n');

    // Detailed Test Results
    print('📋 CHI TIẾT CÁC TEST:\n');

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final isLast = i == steps.length - 1;
      final prefix = isLast ? '└─' : '├─';
      final statusIcon = _getStatusIcon(step.status);
      final statusText = _getStatusText(step.status);

      print('   $prefix [$statusIcon] ${step.title}');
      print('   ${isLast ? "  " : "│"}     Status: $statusText');
      print(
        '   ${isLast ? "  " : "│"}     Type: ${step.kind == DiagKind.auto ? "Auto" : "Manual"}',
      );

      if (step.note != null && step.note!.isNotEmpty) {
        print('   ${isLast ? "  " : "│"}     Note: ${step.note}');
      }

      if (!isLast) print('   │');
    }

    print('\n╔═══════════════════════════════════════���════════════════════╗');
    print('║  Generated: ${DateTime.now().toString().split('.')[0]}   ║');
    print('╚════════════════════════════════════════════════════════════╝\n');
  }

  // Helper method to convert bytes to GiB with standard rounding
  int? _toGiB(dynamic v) {
    if (v is! num) return null;
    const giB = 1024 * 1024 * 1024;
    final gb = v.toDouble() / giB;

    // Làm tròn theo các mức chuẩn: 2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512
    const standardSizes = [2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512, 1024];

    // Tìm mức gần nhất
    int closest = standardSizes[0];
    double minDiff = (gb - closest).abs();

    for (final size in standardSizes) {
      final diff = (gb - size).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }

    return closest;
  }

  // Helper method to calculate grade
  String _calculateGrade(int score) {
    if (score >= 90) return 'Loại 1 (Xuất sắc)';
    if (score >= 75) return 'Loại 2 (Tốt)';
    if (score >= 60) return 'Loại 3 (Khá)';
    if (score >= 40) return 'Loại 4 (Trung bình)';
    return 'Loại 5 (Cần cải thiện)';
  }

  // Helper method to get status icon
  String _getStatusIcon(DiagStatus status) {
    switch (status) {
      case DiagStatus.passed:
        return '✓';
      case DiagStatus.failed:
        return '✗';
      case DiagStatus.running:
        return '⟳';
      case DiagStatus.skipped:
        return '○';
      default:
        return '◌';
    }
  }

  // Helper method to get status text
  String _getStatusText(DiagStatus status) {
    switch (status) {
      case DiagStatus.passed:
        return 'PASSED';
      case DiagStatus.failed:
        return 'FAILED';
      case DiagStatus.running:
        return 'RUNNING';
      case DiagStatus.skipped:
        return 'SKIPPED';
      default:
        return 'PENDING';
    }
  }

  // ================== INFO / SNAPSHOTS ==================
  Future<bool> _snapBattery() async {
    info['battery'] = await _getBatteryInfo();
    return true;
  }

  Future<bool> _snapOsModel() async {
    info['osmodel'] = await _getOsAndModel();

    // Kiểm tra OS requirements
    final osInfo = info['osmodel'] as Map<String, dynamic>;
    final platform = osInfo['platform'] as String?;
    final sdkInt = osInfo['sdk'] as int?;
    final release = osInfo['release'] as String?;

    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║           KIỂM TRA YÊU CẦU HỆ ĐIỀU HÀNH                  ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    if (platform == 'android') {
      print('📱 Platform: Android');
      print('   ├─ SDK Level: ${sdkInt ?? "N/A"}');
      print('   ├─ Android Version: ${release ?? "N/A"}');
      print('   └─ Yêu cầu: Android 5.0 (API 21) trở lên\n');

      // Android 5.0 = API 21
      final meetsAndroidRequirement = sdkInt != null && sdkInt >= 21;

      if (meetsAndroidRequirement) {
        print('✅ KẾT QUẢ: ĐẠT YÊU CẦU');
        print(
          '   └─ Thiết bị hỗ trợ Android ${release ?? sdkInt} (API $sdkInt)',
        );
      } else {
        print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
        print(
          '   └─ Thiết bị chỉ hỗ trợ Android ${release ?? sdkInt} (API ${sdkInt ?? "N/A"})',
        );
        print('   └─ Cần nâng cấp lên Android 5.0 trở lên');
      }
    } else if (platform == 'ios') {
      final systemVersion = osInfo['systemVersion'] as String?;
      print('📱 Platform: iOS');
      print('   ├─ iOS Version: ${systemVersion ?? "N/A"}');
      print('   └─ Yêu cầu: iOS 10.0 trở lên\n');

      // Parse iOS version
      final versionParts = systemVersion?.split('.') ?? [];
      final majorVersion =
          versionParts.isNotEmpty ? int.tryParse(versionParts[0]) : null;
      final meetsIOSRequirement = majorVersion != null && majorVersion >= 10;

      if (meetsIOSRequirement) {
        print('✅ KẾT QUẢ: ĐẠT YÊU CẦU');
        print('   └─ Thiết bị hỗ trợ iOS $systemVersion');
      } else {
        print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
        print('   └─ Thiết bị chỉ hỗ trợ iOS ${systemVersion ?? "N/A"}');
        print('   └─ Cần nâng cấp lên iOS 10.0 trở lên');
      }
    } else {
      print('⚠️  Platform: Unknown');
      print('   └─ Không thể xác định hệ điều hành');
    }

    print('╚═══════════════════════════════════════════════════════════╝\n');

    return true;
  }

  Future<bool> _snapMobile() async {
    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║           KIỂM TRA MẠNG DI ĐỘNG                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    // Kiểm tra quyền READ_PHONE_STATE (bắt buộc)
    final phonePermission = await Permission.phone.status;
    print(
      '🔐 Quyền READ_PHONE_STATE: ${phonePermission.isGranted ? "Đã cấp" : "Chưa cấp"}',
    );

    if (!phonePermission.isGranted) {
      print('   └─ Đang yêu cầu quyền...\n');

      final result = await Permission.phone.request();

      if (result.isGranted) {
        print('✅ Đã cấp quyền READ_PHONE_STATE');
      } else if (result.isDenied) {
        print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
        print('   ├─ Người dùng từ chối cấp quyền READ_PHONE_STATE');
        print('   └─ Không thể kiểm tra thông tin mạng di động');
        print(
          '╚═══════════════════════════════════════════════════════════╝\n',
        );
        return false;
      } else if (result.isPermanentlyDenied) {
        print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
        print('   ├─ Quyền READ_PHONE_STATE bị từ chối vĩnh viễn');
        print('   ├─ Vui lòng vào Cài đặt > Ứng dụng > Quyền để cấp quyền');
        print('   └─ Không thể kiểm tra thông tin mạng di động');
        print(
          '╚═══════════════════════════════════════════════════════════╝\n',
        );

        // Mở settings
        await openAppSettings();
        return false;
      }
    }

    // Lấy thông tin mạng di động
    info['mobile'] = await _getMobileNetworkInfo();
    final mobileInfo = info['mobile'] as Map<String, dynamic>;
    final connected = mobileInfo['connected'] as bool? ?? false;
    final radio = mobileInfo['radio'] as String?;
    final dbm = mobileInfo['dbm'] as int?;

    print(
      '\n📶 Trạng thái kết nối: ${connected ? "Đã kết nối" : "Chưa kết nối"}',
    );

    if (connected && radio != null) {
      print('   ├─ Loại mạng: $radio');
      print('   ├─ Cường độ tín hiệu: ${dbm != null ? "$dbm dBm" : "N/A"}');
      print('   └─ Yêu cầu: 3G trở lên\n');

      // Kiểm tra có phải 3G trở lên không
      final is3GOrHigher = _is3GOrHigher(radio);

      if (is3GOrHigher) {
        print('✅ KẾT QUẢ: ĐẠT YÊU CẦU');
        print('   └─ Thiết bị hỗ trợ mạng $radio (3G trở lên)');
      } else {
        print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
        print('   └─ Thiết bị chỉ hỗ trợ mạng $radio (dưới 3G)');
        print('   └─ Cần hỗ trợ 3G, 4G/LTE hoặc 5G');
      }
    } else {
      print('   └─ Không có kết nối mạng di động\n');
      print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
      print('   ├─ Không phát hiện kết nối mạng di động');
      print('   └─ Vui lòng bật dữ liệu di động và thử lại');
    }

    print('╚═══════════════════════════════════════════════════════════╝\n');

    return connected && radio != null && _is3GOrHigher(radio);
  }

  bool _is3GOrHigher(String radio) {
    // 3G and higher: HSPA, HSDPA, HSUPA, HSPAP, LTE, NR (5G)
    // Below 3G: GPRS, EDGE, UNKNOWN
    final radio3GOrHigher = ['HSPA', 'HSDPA', 'HSUPA', 'HSPAP', 'LTE', 'NR'];
    return radio3GOrHigher.contains(radio.toUpperCase());
  }

  Future<bool> _snapWifi() async {
    info['wifi'] = await _getWifiInfo();

    final wifiInfo = info['wifi'] as Map<String, dynamic>;
    final enabled = wifiInfo['enabled'] as bool? ?? false;
    final connected = wifiInfo['connected'] as bool? ?? false;
    final ssid = wifiInfo['ssid'] as String?;

    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║           KIỂM TRA WIFI                                   ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    // Trường hợp 1: WiFi không được bật
    if (!enabled) {
      print('📡 Trạng thái WiFi: TẮT');
      print('   └─ WiFi chưa được bật trên thiết bị\n');
      print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
      print('   ├─ WiFi phải được bật để kiểm tra');
      print('   └─ Vui lòng bật WiFi trong Cài đặt');
      print('╚═══════════════════════════════════════════════════════════╝\n');
      return false;
    }

    // Trường hợp 2: WiFi bật nhưng không kết nối
    if (enabled && !connected) {
      print('📡 Trạng thái WiFi: BẬT');
      print('   ├─ Trạng thái kết nối: CHƯA KẾT NỐI');
      print('   └─ Chưa kết nối đến mạng WiFi nào\n');
      print('❌ KẾT QUẢ: KHÔNG ĐẠT YÊU CẦU');
      print('   ├─ WiFi đã bật nhưng chưa kết nối mạng');
      print('   └─ Vui lòng kết nối đến một mạng WiFi');
      print('╚═══════════════════════════════════════════════════════════╝\n');
      return false;
    }

    // Trường hợp 3: WiFi bật và đã kết nối
    if (enabled && connected) {
      print('📡 Trạng thái WiFi: BẬT');
      print('   ├─ Trạng thái kết nối: ĐÃ KẾT NỐI');

      if (ssid != null && ssid.isNotEmpty) {
        // Remove quotes from SSID if present
        final cleanSsid = ssid.replaceAll('"', '');
        print('   ├─ Tên mạng (SSID): $cleanSsid');
      } else {
        print('   ├─ Tên mạng (SSID): Không xác định');
        print('   │  (Cần quyền ACCESS_FINE_LOCATION để đọc SSID)');
      }

      print('   └─ Chất lượng kết nối: Tốt\n');
      print('✅ KẾT QUẢ: ĐẠT YÊU CẦU');
      print('   └─ WiFi hoạt động bình thường');
      print('╚═══════════════════════════════════════════════════════════╝\n');
      return true;
    }

    // Trường hợp không xác định
    print('⚠️  Trạng thái WiFi: KHÔNG XÁC ĐỊNH');
    print('╚═══════════════════════════════════════════════════════════╝\n');
    return false;
  }

  // NEW: RAM/ROM snapshots
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

  // ---- implement details ----
  Future<Map<String, dynamic>> _getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return {'level': level, 'state': state.name};
  }

  String _getOriginCountry(String brand, String manufacturer) {
    final brandLower = brand.toLowerCase();
    final manuLower = manufacturer.toLowerCase();

    // Korean brands
    if (brandLower.contains('samsung') || manuLower.contains('samsung'))
      return 'Hàn Quốc';
    if (brandLower.contains('lg') || manuLower.contains('lg'))
      return 'Hàn Quốc';

    // Chinese brands
    if (brandLower.contains('xiaomi') || manuLower.contains('xiaomi'))
      return 'Trung Quốc';
    if (brandLower.contains('oppo') || manuLower.contains('oppo'))
      return 'Trung Quốc';
    if (brandLower.contains('vivo') || manuLower.contains('vivo'))
      return 'Trung Quốc';
    if (brandLower.contains('huawei') || manuLower.contains('huawei'))
      return 'Trung Quốc';
    if (brandLower.contains('oneplus') || manuLower.contains('oneplus'))
      return 'Trung Quốc';
    if (brandLower.contains('realme') || manuLower.contains('realme'))
      return 'Trung Quốc';
    if (brandLower.contains('honor') || manuLower.contains('honor'))
      return 'Trung Quốc';
    if (brandLower.contains('zte') || manuLower.contains('zte'))
      return 'Trung Quốc';
    if (brandLower.contains('lenovo') || manuLower.contains('lenovo'))
      return 'Trung Quốc';
    if (brandLower.contains('meizu') || manuLower.contains('meizu'))
      return 'Trung Quốc';
    if (brandLower.contains('tcl') || manuLower.contains('tcl'))
      return 'Trung Quốc';

    // American brands
    if (brandLower.contains('apple') || manuLower.contains('apple'))
      return 'Mỹ';
    if (brandLower.contains('google') || manuLower.contains('google'))
      return 'Mỹ';
    if (brandLower.contains('motorola') || manuLower.contains('motorola'))
      return 'Mỹ';

    // Japanese brands
    if (brandLower.contains('sony') || manuLower.contains('sony'))
      return 'Nhật Bản';
    if (brandLower.contains('sharp') || manuLower.contains('sharp'))
      return 'Nhật Bản';
    if (brandLower.contains('fujitsu') || manuLower.contains('fujitsu'))
      return 'Nhật Bản';

    // Taiwanese brands
    if (brandLower.contains('asus') || manuLower.contains('asus'))
      return 'Đài Loan';
    if (brandLower.contains('htc') || manuLower.contains('htc'))
      return 'Đài Loan';
    if (brandLower.contains('acer') || manuLower.contains('acer'))
      return 'Đài Loan';

    // Finnish brands
    if (brandLower.contains('nokia') || manuLower.contains('nokia'))
      return 'Phần Lan';

    return 'Không xác định';
  }

  Future<Map<String, dynamic>> _getOsAndModel() async {
    try {
      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        final vendor = a.manufacturer.toLowerCase();
        final origin = _getOriginCountry(a.brand, a.manufacturer);

        // Get marketing name using mapper
        String marketingName = DeviceNameMapper.getMarketingName(
          a.model,
          a.brand,
        );

        // Try to get marketing name from API (async)
        _fetchMarketingNameFromAPI(a.model, a.brand);

        return {
          'platform': 'android',
          'sdk': a.version.sdkInt,
          'release': a.version.release,
          'model': a.model,
          'marketingName': marketingName,
          'brand': a.brand, // Ensure this isn't empty on generic emulators
          'manufacturer': a.manufacturer,
          'vendor': vendor,
          'origin': origin,
          'isSamsung': vendor == 'samsung',
          'isApple': false,
        };
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        // Map machine ID to marketing name (e.g. iPhone16,2 -> iPhone 15 Pro Max)
        // We can reuse DeviceInfoHelper's mapping logic or call it directly if possible.
        // But DeviceInfoHelper.getModel() calls iosInfo again. It's efficient enough.
        final machine = i.utsname.machine;
        // Simple mapping reusing DeviceInfoHelper logic is safer:
        // Or duplicate logic here for speed? Use mapped name as marketing name.

        // Get friendly name from helper
        final friendlyName = await DeviceInfoHelper.getModel();

        return {
          'platform': 'ios',
          'systemVersion': i.systemVersion,
          'model': machine,
          'marketingName': friendlyName, // Better than i.name
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
      print('Error getting OS info: $e');
      return {'platform': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _getMobileNetworkInfo() async {
    final conn = await Connectivity().checkConnectivity();
    final onMobile = conn.contains(ConnectivityResult.mobile);
    int? dbm;
    String? radio;
    if (onMobile) {
      // Use DeviceInfoHelper for cross-platform support
      final sig = await DeviceInfoHelper.getSignalStrength();
      dbm = sig['dbm'];
      radio = await _invoke<String>('getMobileRadioType');
    }
    return {'connected': onMobile, 'dbm': dbm, 'radio': radio};
  }

  Future<Map<String, dynamic>> _getWifiInfo() async {
    // Kiểm tra WiFi có được bật không (qua native)
    bool? wifiEnabled = await _invoke<bool>('isWifiEnabled');

    final conn = await Connectivity().checkConnectivity();
    final onWifi =
        conn.contains(ConnectivityResult.wifi) ||
        conn.contains(ConnectivityResult.ethernet);
    String? ssid;
    if (onWifi) {
      try {
        if (await Permission.locationWhenInUse.request().isGranted) {
          ssid = await NetworkInfo().getWifiName();
        }
      } catch (_) {}
    }
    return {
      'enabled': wifiEnabled ?? onWifi,
      'connected': onWifi,
      'ssid': ssid,
    };
  }

  /// Lấy thông tin RAM (có iOS fallback)
  Future<Map<String, dynamic>> _getRamInfo() async {
    try {
      return await DeviceInfoHelper.getRamInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  /// Lấy thông tin ROM/Storage (có iOS fallback)
  Future<Map<String, dynamic>> _getRomInfo() async {
    try {
      return await DeviceInfoHelper.getRomInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  Future<Map<String, dynamic>> _getBluetoothInfo() async {
    var state = FlutterBluePlus.adapterStateNow;
    if (state != BluetoothAdapterState.on) {
      try {
        state = await FlutterBluePlus.adapterState.first.timeout(
          const Duration(milliseconds: 500),
        );
      } catch (_) {}
    }
    bool scanOk = false;
    if (state == BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
        await Future.delayed(const Duration(seconds: 2));
        await FlutterBluePlus.stopScan();
        scanOk = true;
      } catch (_) {}
    }
    return {'enabled': state == BluetoothAdapterState.on, 'scanOk': scanOk};
  }

  Future<Map<String, dynamic>> _getNfcInfo() async {
    bool available = false;
    try {
      available = await NfcManager.instance.isAvailable();
    } catch (_) {}
    return {'available': available};
  }

  Future<Map<String, dynamic>> _getSimInfo() async {
    return await DeviceInfoHelper.getSimInfo();
  }

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
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    final svc = await Geolocator.isLocationServiceEnabled();
    double? accuracy;
    if (svc &&
        (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse)) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        accuracy = pos.accuracy;
      } catch (_) {}
    }
    return {'serviceOn': svc, 'accuracyM': accuracy};
  }

  Future<Map<String, dynamic>> _getChargingInfo() async {
    final state = await _battery.batteryState;
    final src = await _invoke<String>('getChargingSource');
    return {'state': state.name, 'source': src};
  }

  Future<bool?> _isWiredHeadsetPlugged() async =>
      await _invoke<bool>('isWiredHeadsetPlugged');

  Future<bool?> _isScreenLocked() async =>
      await _invoke<bool>('isScreenLocked');

  Future<bool> _isSPenSupported() async =>
      (await _invoke<bool>('isSPenSupported')) == true;

  Future<Map<String, dynamic>> _checkBiometrics() async {
    final la = LocalAuthentication();
    bool can = false, supported = false;
    try {
      can = await la.canCheckBiometrics;
      supported = await la.isDeviceSupported();
    } catch (_) {}
    return {'canCheck': can, 'supported': supported};
  }

  // ================== INTERACTIVE ==================
  Future<bool> _testVibration() async {
    try {
      final has = (await Vibration.hasVibrator()) == true;
      if (!has) return false;

      // Random 1-3 lần rung
      final random = math.Random();
      final vibrationCount = random.nextInt(3) + 1; // 1, 2, hoặc 3

      for (int i = 0; i < vibrationCount; i++) {
        await Vibration.vibrate(duration: 300);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Hiện dialog cho user chọn số lần rung
      final result = await Get.dialog<int>(
        AlertDialog(
          title: const Text('Kiểm tra rung'),
          content: const Text('Máy vừa rung bao nhiêu lần?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: 0),
              child: const Text('Không rung'),
            ),
            TextButton(
              onPressed: () => Get.back(result: 1),
              child: const Text('1 lần'),
            ),
            TextButton(
              onPressed: () => Get.back(result: 2),
              child: const Text('2 lần'),
            ),
            TextButton(
              onPressed: () => Get.back(result: 3),
              child: const Text('3 lần'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      // Pass nếu user chọn đúng số lần rung
      return result == vibrationCount;
    } catch (_) {
      return false;
    }
  }

  Future<bool> Function() _confirm(String msg) => () async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Không đạt'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đạt'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return ok == true;
  };

  Future<bool> _openTouchGrid() async =>
      (await Get.to<bool>(() => const TouchGridTestPage())) == true;

  /// Tự động test màn hình (không cần user interaction)
  Future<bool> _testScreenAuto() async {
    try {
      print('🖥️ Bắt đầu test màn hình tự động...');

      // Hiển thị các màu và tự động phân tích
      final result = await Get.to<Map<String, dynamic>?>(
        () => const ScreenDefectDetectionPage(),
      );

      if (result == null) return false;

      // Lưu thông tin lỗi màn hình
      info['screen'] = result;

      // Pass nếu không có lỗi
      final passed = result['passed'] == true;
      final defectCount = result['defectCount'] as int? ?? 0;

      if (!passed && defectCount > 0) {
        print('⚠️ Phát hiện $defectCount lỗi màn hình');
        final defects = result['defects'] as List? ?? [];
        for (var defect in defects) {
          print('   - ${defect['type']}: ${defect['description']}');
        }
      } else {
        print('✅ Màn hình không có lỗi');
      }

      return passed;
    } catch (e) {
      print('❌ Lỗi test màn hình: $e');
      return false;
    }
  }

  Future<bool> _openScreenDefectDetection() async {
    final result = await Get.to<Map<String, dynamic>?>(
      () => const ScreenDefectDetectionPage(),
    );

    if (result == null) return false;

    // Lưu thông tin lỗi màn hình
    info['screen'] = result;

    // Pass nếu không có lỗi
    final passed = result['passed'] == true;
    final defectCount = result['defectCount'] as int? ?? 0;

    if (!passed && defectCount > 0) {
      print('⚠️ Phát hiện $defectCount lỗi màn hình');
    }

    return passed;
  }

  Future<bool> _openScreenBurnInTest() async {
    // Tier 5 (máy cũ/giá thấp) → tự động test
    if (_profile?.shouldAutoTestScreen == true) {
      return (await Get.to<bool>(() => const AutoScreenBurnInTestPage())) ==
          true;
    }
    // Các tier khác → manual test
    return (await Get.to<bool>(() => const ScreenBurnInTestPage())) == true;
  }

  Future<bool> _openCameraQuick() async {
    try {
      final st = await [Permission.camera].request();
      if (st[Permission.camera] != PermissionStatus.granted) return false;
      if (_cams.isEmpty) return false;

      // Use advanced camera test with specs, obstruction & shake detection
      final ok = await Get.to<bool>(
        () => AdvancedCameraTestPage(cameras: _cams),
      );
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openSpeakerTest() async =>
      (await Get.to<bool>(() => const SpeakerTestPage())) == true;

  Future<bool> _openMicTest() async =>
      (await Get.to<bool>(() => const MicTestPage())) == true;

  Future<bool> _openEarpieceTest() async =>
      (await Get.to<bool>(() => const EarpieceTestPage())) == true;

  Future<bool> _openKeysTest() async {
    final result = await Get.to<Map<String, dynamic>?>(
      () => const KeysTestPage(),
    );
    if (result == null) return false;
    // Store granular result for evaluator
    info['keys'] = result;
    // Basic pass condition: userConfirm flag present & true OR both volume keys
    final passed =
        (result['userConfirm'] == true) ||
        (result['volumeUp'] == true && result['volumeDown'] == true);
    return passed;
  }

  // ================== PHONE INFO API ==================
  /// Fetch marketing name from API and update
  Future<void> _fetchMarketingNameFromAPI(String model, String brand) async {
    try {
      final marketingName = await PhoneInfoService.getMarketingName(
        model,
        brand,
      );
      if (marketingName != null && marketingName.isNotEmpty) {
        // Update marketing name in info
        if (info['osmodel'] != null) {
          info['osmodel']['marketingName'] = marketingName;
          update(); // Notify listeners
          print('✓ Updated marketing name from API: $marketingName');
        }
      }
    } catch (e) {
      print('Error fetching marketing name from API: $e');
    }
  }

  /// Fetch phone image URL from API
  Future<String?> getPhoneImageUrl() async {
    try {
      final model = modelName;
      final brandName = brand;
      return await PhoneInfoService.getPhoneImageUrl(model, brandName);
    } catch (e) {
      print('Error fetching phone image URL: $e');
      return null;
    }
  }

  /// Get full phone info from API
  Future<PhoneInfo?> getPhoneInfo() async {
    try {
      final model = modelName;
      final brandName = brand;
      return await PhoneInfoService.getPhoneInfo(model, brandName);
    } catch (e) {
      print('Error fetching phone info: $e');
      return null;
    }
  }
}
