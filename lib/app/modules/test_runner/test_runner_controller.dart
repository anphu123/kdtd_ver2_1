import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Trans;
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import 'package:kdtd_ver2_1/app/core/constants/diagnostics_constants.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/data/model/device_profile.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_environment.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/model/function_attribute.dart';
import 'package:kdtd_ver2_1/app/data/services/device_hardware_service.dart';
import 'package:kdtd_ver2_1/app/data/services/diag_logger.dart';
import 'package:kdtd_ver2_1/app/data/services/profile_manager.dart';
import 'package:kdtd_ver2_1/app/data/services/rule_evaluator.dart';
import 'package:kdtd_ver2_1/app/modules/camera_test/camera_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/camera_test/camera_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/earpiece_test/earpiece_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/earpiece_test/earpiece_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/failed_tests_warning/failed_tests_warning_page.dart';
import 'package:kdtd_ver2_1/app/modules/keys_test/keys_test_controller.dart';
import 'package:kdtd_ver2_1/app/modules/mic_test/mic_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/mic_test/mic_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/speaker_test/speaker_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/speaker_test/speaker_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/touch_grid_test/touch_grid_test_binding.dart';
import 'package:kdtd_ver2_1/app/modules/touch_grid_test/touch_grid_test_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// TestRunnerController - Điều phối quá trình thực thi các bài kiểm tra chức năng
class TestRunnerController extends GetxController {
  // ==================== REACTIVE STATE ====================
  final steps = <DiagStep>[].obs;
  final isRunning = false.obs;
  final passedCount = 0.obs;
  final failedCount = 0.obs;
  final skippedCount = 0.obs;
  final info = <String, dynamic>{}.obs;

  final currentPhase = Rx<DiagPhase>(DiagPhase.connectivity);
  final phaseProgress = 0.obs;
  final phaseTotal = 0.obs;

  int get total => steps.length;
  int get completed =>
      passedCount.value + failedCount.value + skippedCount.value;
  int get score => total > 0 ? (passedCount.value * 100 / total).round() : 0;
  String get grade {
    if (score >= 90) return LocaleKeys.diagnostics_home_grade_excellent.trans();
    if (score >= 75) return LocaleKeys.diagnostics_home_grade_good.trans();
    if (score >= 60) return LocaleKeys.diagnostics_home_grade_fair.trans();
    if (score >= 40) return LocaleKeys.diagnostics_home_grade_average.trans();
    return LocaleKeys.diagnostics_home_grade_needs_improvement.trans();
  }

  // ==================== GROUPED VIEW ====================
  List<DiagStep> stepsForPhase(DiagPhase phase) =>
      steps.where((s) => s.phase == phase).toList();

  int passedCountForPhase(DiagPhase phase) =>
      stepsForPhase(phase).where((s) => s.status == DiagStatus.passed).length;

  bool isPhaseCompleted(DiagPhase phase) {
    final phaseSteps = stepsForPhase(phase);
    return phaseSteps.isNotEmpty &&
        passedCountForPhase(phase) == phaseSteps.length;
  }

  RuleEvaluator? _evaluator;
  DeviceProfile? profile;
  DiagEnvironment _environment = const DiagEnvironment();
  List<CameraDescription> _cams = [];
  DateTime? _startTime;

  @override
  void onInit() {
    super.onInit();
    steps.assignAll(_buildFunctionalSteps());
    _prepareCameras();
    _initializeEvaluator();
  }

  /// Nạp thông tin ban đầu (từ trang Home hoặc quét sơ bộ)
  void setInitialInfo(Map<String, dynamic> initialInfo) {
    info.addAll(initialInfo);
    _initializeEvaluator();
  }

  Future<void> _prepareCameras() async {
    try {
      _cams = await availableCameras();
      final front =
          _cams
              .where((c) => c.lensDirection == CameraLensDirection.front)
              .toList();
      final back =
          _cams
              .where((c) => c.lensDirection == CameraLensDirection.back)
              .toList();

      info['camera_specs'] = {
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
    } catch (_) {
      info['camera_specs'] = {'total': 0, 'front': 0, 'back': 0, 'cameras': []};
    }
  }

  Future<void> _initializeEvaluator() async {
    try {
      final osInfo = info['osmodel'] as Map<String, dynamic>? ?? {};
      final deviceBrand = osInfo['brand'] as String? ?? '';
      final deviceModel = osInfo['model'] as String? ?? '';

      final profileManager = await ProfileManager.getInstance();
      profile = profileManager.getProfile(deviceModel, deviceBrand);

      await _updateEnvironment();
      _evaluator = await RuleEvaluator.create(
        profile: profile!,
        environment: _environment,
      );
    } catch (e) {
      DiagLogger.error('init', 'Lỗi khởi tạo evaluator: $e');
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
    final osInfo = info['osmodel'] as Map<String, dynamic>? ?? {};

    _environment = DiagEnvironment(
      brand: osInfo['brand'] as String? ?? '',
      platform: osInfo['platform'] as String? ?? 'unknown',
      locationServiceOn: locationOn,
      deniedPerms: deniedPerms,
      grantedPerms: grantedPerms,
      sensors: {
        'accelerometer': sensorInfo['accelerometer'] == true,
        'gyroscope': sensorInfo['gyroscope'] == true,
      },
    );
  }

  // ==================== STEP DEFINITIONS (Flow 3) ====================
  List<DiagStep> _buildFunctionalSteps() {
    return [
      // ========== 1..4 AUTO CHECKS ==========
      DiagStep(
        code: 'wifi',
        title: LocaleKeys.diagnostics_home_step_wifi_title.trans(),
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 5),
        functionAttribute: FunctionAttribute.wifi,
        run: _snapWifi,
      ),
      DiagStep(
        code: 'bluetooth',
        title: LocaleKeys.diagnostics_home_step_bt_title.trans(),
        kind: DiagKind.auto,
        phase: DiagPhase.connectivity,
        timeout: const Duration(seconds: 5),
        functionAttribute: FunctionAttribute.bluetooth,
        run: _checkBluetooth,
      ),
      DiagStep(
        code: 'location',
        title: LocaleKeys.diagnostics_home_step_gps_title.trans(),
        kind: DiagKind.auto,
        phase: DiagPhase.sensors,
        timeout: const Duration(seconds: 10),
        functionAttribute: FunctionAttribute.location,
        run: _snapLocation,
      ),
      DiagStep(
        code: 'vibration',
        title: LocaleKeys.diagnostics_home_step_vibrate_title.trans(),
        kind: DiagKind.auto,
        phase: DiagPhase.hardware,
        timeout: const Duration(seconds: 10),
        functionAttribute: FunctionAttribute.vibration,
        run: _testVibration,
      ),

      // ========== 5..13 MANUAL CHECKS ==========
      DiagStep(
        code: 'biometrics',
        title: LocaleKeys.diagnostics_home_step_bio_title.trans(),
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 30),
        functionAttribute: FunctionAttribute.biometrics,
        interact: _testBiometrics,
      ),
      DiagStep(
        code: 'mic',
        title: LocaleKeys.diagnostics_home_step_mic_title.trans(),
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        functionAttribute: FunctionAttribute.mic,
        interact: _openMicTest,
      ),
      DiagStep(
        code: 'volume-up',
        title: 'Nút tăng âm lượng (+)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 30),
        functionAttribute: FunctionAttribute.volumeUp,
        interact: _openVolumeUpTest,
      ),
      DiagStep(
        code: 'volume-down',
        title: 'Nút giảm âm lượng (-)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 30),
        functionAttribute: FunctionAttribute.volumeDown,
        interact: _openVolumeDownTest,
      ),
      DiagStep(
        code: 'front-camera',
        title: 'Camera trước',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        functionAttribute: FunctionAttribute.frontCamera,
        interact: _openFrontCameraTest,
      ),
      DiagStep(
        code: 'rear-camera',
        title: 'Camera sau (Tất cả camera)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 120),
        functionAttribute: FunctionAttribute.rearCamera,
        interact: _openRearCameraTest,
      ),
      DiagStep(
        code: 'external-speaker',
        title: 'Loa ngoài',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        functionAttribute: FunctionAttribute.externalSpeaker,
        interact: _openSpeakerTest,
      ),
      DiagStep(
        code: 'internal-speaker',
        title: 'Loa trong (Earpiece)',
        kind: DiagKind.manual,
        phase: DiagPhase.manual,
        timeout: const Duration(seconds: 60),
        functionAttribute: FunctionAttribute.internalSpeaker,
        interact: _openEarpieceTest,
      ),
      DiagStep(
        code: 'touch-screen',
        title: 'Cảm ứng màn hình',
        kind: DiagKind.manual,
        phase: DiagPhase.screen,
        timeout: const Duration(seconds: 60),
        functionAttribute: FunctionAttribute.touchScreen,
        interact: _openTouchGrid,
      ),
    ];
  }

  // ==================== AUTO SNAPSHOT RUNNERS (Flow 3) ====================
  Future<bool> _snapWifi() async {
    info['wifi'] = await DeviceHardwareService.getWifiInfo();
    final wifiInfo = info['wifi'] as Map<String, dynamic>;
    final ok = (wifiInfo['enabled'] as bool? ?? false) ||
        (wifiInfo['connected'] as bool? ?? false);
    debugPrint('[TestRunner] Kết quả Wi-Fi: $ok ($wifiInfo)');
    return ok;
  }

  Future<bool> _checkBluetooth() async {
    info['bluetooth'] = await DeviceHardwareService.getBluetoothInfo();
    final btInfo = info['bluetooth'] as Map<String, dynamic>;
    final ok = btInfo['enabled'] == true;
    debugPrint('[TestRunner] Kết quả Bluetooth: $ok ($btInfo)');
    return ok;
  }

  Future<bool> _snapLocation() async {
    info['location'] = await DeviceHardwareService.getLocationAccuracy();
    final loc = info['location'] as Map<String, dynamic>;
    final ok = loc['serviceOn'] == true;
    debugPrint('[TestRunner] Kết quả GPS/Định vị: $ok ($loc)');
    return ok;
  }

  // ==================== INTERACTIVE TESTS (Flow 3) ====================
  Future<bool> _testVibration() async {
    try {
      final hasVibrator = (await Vibration.hasVibrator()) == true;
      if (!hasVibrator) {
        debugPrint('[TestRunner] Thiết bị không hỗ trợ motor rung');
        return true;
      }

      debugPrint('[TestRunner] Kích hoạt kiểm tra motor rung...');
      await Vibration.vibrate(duration: 400);
      return true;
    } catch (e) {
      debugPrint('[TestRunner] Lỗi khi test rung: $e');
      return false;
    }
  }

  Future<bool> _testBiometrics() async {
    debugPrint('[TestRunner] Bắt đầu kiểm tra Sinh trắc học...');
    try {
      final bioInfo = await DeviceHardwareService.checkBiometrics();
      if (bioInfo['canCheck'] != true && bioInfo['supported'] != true) {
        debugPrint('[TestRunner] Thiết bị không hỗ trợ hoặc chưa đăng ký sinh trắc học');
        return true;
      }
      final la = LocalAuthentication();
      final authenticated = await la.authenticate(
        localizedReason: 'Xác thực vân tay / Face ID để kiểm tra cảm biến sinh trắc học',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      debugPrint('[TestRunner] Kết quả xác thực sinh trắc học: $authenticated');
      return authenticated;
    } catch (e) {
      debugPrint('[TestRunner] Lỗi kiểm tra sinh trắc học: $e');
      return false;
    }
  }

  Future<bool> _openMicTest() async {
    debugPrint('[TestRunner] Mở màn hình kiểm tra Microphone [MicTestPage]...');
    final result = (await Get.to<bool>(
      () => const MicTestPage(),
      binding: MicTestBinding(),
    )) == true;
    debugPrint('[TestRunner] Kết quả kiểm tra Microphone: $result');
    return result;
  }

  Future<bool> _openVolumeUpTest() async {
    debugPrint('[TestRunner] Bắt đầu kiểm tra phím Tăng âm lượng (+)...');
    final keysController = Get.isRegistered<KeysTestController>()
        ? Get.find<KeysTestController>()
        : Get.put(KeysTestController());

    final completer = Completer<bool>();
    final waitFuture = keysController.waitForKey(24, seconds: 6);

    Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.volume_up_rounded, color: AppColors.tradeInBlue),
            SizedBox(width: 8),
            Text('Nút Tăng âm lượng (+)'),
          ],
        ),
        content: const Text(
          'Vui lòng bấm nút TĂNG âm lượng (+) trên thân máy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Bỏ qua / Hỏng'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Phím hoạt động tốt'),
          ),
        ],
      ),
      barrierDismissible: false,
    ).then((userResult) {
      if (!completer.isCompleted) completer.complete(userResult ?? false);
    });

    waitFuture.then((pressed) {
      if (pressed && !completer.isCompleted) {
        if (Get.isDialogOpen == true) Get.back(result: true);
        completer.complete(true);
      }
    });

    final res = await completer.future;
    debugPrint('[TestRunner] Kết quả nút Tăng âm lượng: $res');
    return res;
  }

  Future<bool> _openVolumeDownTest() async {
    debugPrint('[TestRunner] Bắt đầu kiểm tra phím Giảm âm lượng (-)...');
    final keysController = Get.isRegistered<KeysTestController>()
        ? Get.find<KeysTestController>()
        : Get.put(KeysTestController());

    final completer = Completer<bool>();
    final waitFuture = keysController.waitForKey(25, seconds: 6);

    Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.volume_down_rounded, color: AppColors.tradeInBlue),
            SizedBox(width: 8),
            Text('Nút Giảm âm lượng (-)'),
          ],
        ),
        content: const Text(
          'Vui lòng bấm nút GIẢM âm lượng (-) trên thân máy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Bỏ qua / Hỏng'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Phím hoạt động tốt'),
          ),
        ],
      ),
      barrierDismissible: false,
    ).then((userResult) {
      if (!completer.isCompleted) completer.complete(userResult ?? false);
    });

    waitFuture.then((pressed) {
      if (pressed && !completer.isCompleted) {
        if (Get.isDialogOpen == true) Get.back(result: true);
        completer.complete(true);
      }
    });

    final res = await completer.future;
    debugPrint('[TestRunner] Kết quả nút Giảm âm lượng: $res');
    return res;
  }

  Future<bool> _openFrontCameraTest() async {
    try {
      debugPrint('[TestRunner] Yêu cầu quyền camera trước...');
      final st = await [Permission.camera].request();
      if (st[Permission.camera] != PermissionStatus.granted) {
        debugPrint('[TestRunner] Không được cấp quyền camera');
        return false;
      }
      if (_cams.isEmpty) {
        _cams = await availableCameras();
      }
      final frontCams = _cams
          .where((c) => c.lensDirection == CameraLensDirection.front)
          .toList();
      final targetCams = frontCams.isNotEmpty ? frontCams : _cams;

      debugPrint('[TestRunner] Mở màn hình kiểm tra Camera trước (${targetCams.length} cam)...');
      final ok = await Get.to<bool>(
        () => const CameraTestPage(),
        binding: CameraTestBinding(),
        arguments: targetCams,
      );
      debugPrint('[TestRunner] Kết quả kiểm tra Camera trước: $ok');
      return ok == true;
    } catch (e) {
      debugPrint('[TestRunner] Lỗi kiểm tra camera trước: $e');
      return false;
    }
  }

  Future<bool> _openRearCameraTest() async {
    try {
      debugPrint('[TestRunner] Yêu cầu quyền camera sau...');
      final st = await [Permission.camera].request();
      if (st[Permission.camera] != PermissionStatus.granted) {
        debugPrint('[TestRunner] Không được cấp quyền camera');
        return false;
      }
      if (_cams.isEmpty) {
        _cams = await availableCameras();
      }
      // Kiểm tra tất cả các cam sau hiện có trên máy (chính, góc rộng, tele, v.v.)
      final backCams = _cams
          .where((c) => c.lensDirection != CameraLensDirection.front)
          .toList();
      final targetCams = backCams.isNotEmpty ? backCams : _cams;

      debugPrint('[TestRunner] Mở màn hình kiểm tra TOÀN BỘ Camera sau (${targetCams.length} cam)...');
      final ok = await Get.to<bool>(
        () => const CameraTestPage(),
        binding: CameraTestBinding(),
        arguments: targetCams,
      );
      debugPrint('[TestRunner] Kết quả kiểm tra Camera sau: $ok');
      return ok == true;
    } catch (e) {
      debugPrint('[TestRunner] Lỗi kiểm tra camera sau: $e');
      return false;
    }
  }

  Future<bool> _openSpeakerTest() async {
    debugPrint('[TestRunner] Mở màn hình kiểm tra loa ngoài [SpeakerTestPage]...');
    final result = (await Get.to<bool>(
      () => const SpeakerTestPage(),
      binding: SpeakerTestBinding(),
    )) == true;
    debugPrint('[TestRunner] Kết quả kiểm tra loa ngoài: $result');
    return result;
  }

  Future<bool> _openEarpieceTest() async {
    debugPrint('[TestRunner] Mở màn hình kiểm tra loa trong/cảm biến tiệm cận [EarpieceTestPage]...');
    final result = (await Get.to<bool>(
      () => const EarpieceTestPage(),
      binding: EarpieceTestBinding(),
    )) == true;
    debugPrint('[TestRunner] Kết quả kiểm tra loa trong: $result');
    return result;
  }

  Future<bool> _openTouchGrid() async {
    debugPrint('[TestRunner] Mở màn hình kiểm tra cảm ứng [TouchGridTestPage]...');
    final result = (await Get.to<bool>(
      () => const TouchGridTestPage(),
      binding: TouchGridTestBinding(),
    )) == true;
    debugPrint('[TestRunner] Kết quả kiểm tra cảm ứng: $result');
    return result;
  }

  // ==================== EXECUTION FLOW ====================
  Future<void> startFunctionalDiagnostics() async {
    if (isRunning.value) return;

    debugPrint('\n============================================================');
    debugPrint('[TestRunner] Bắt đầu thực thi kiểm định chức năng (${steps.length} bài test)');
    debugPrint('============================================================');

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

    await _runPhase(DiagPhase.connectivity);
    await _runPhase(DiagPhase.sensors);
    await _runPhase(DiagPhase.hardware);
    await _runPhase(DiagPhase.screen);
    await _runPhase(DiagPhase.manual);

    isRunning.value = false;
    final totalDuration = DateTime.now().difference(
      _startTime ?? DateTime.now(),
    );

    debugPrint('\n============================================================');
    debugPrint('[TestRunner] HOÀN TẤT KIỂM ĐỊNH CHỨC NĂNG');
    debugPrint('[TestRunner] Passed: ${passedCount.value} | Failed: ${failedCount.value} | Skipped: ${skippedCount.value}');
    debugPrint('[TestRunner] Điểm số: $score/100 | Xếp loại: $grade | Thời gian: ${totalDuration.inSeconds}s');
    debugPrint('============================================================\n');

    DiagLogger.summary(
      total: total,
      passed: passedCount.value,
      failed: failedCount.value,
      skipped: skippedCount.value,
      score: score,
      grade: grade,
      totalDuration: totalDuration,
    );

    printTestResults();
    _navigateToResult();
  }

  void printTestResults() {
    final response = {
      'status': failedCount.value == 0 ? 'success' : 'has_failures',
      'summary': {
        'score': score,
        'grade': grade,
        'total': total,
        'passed': passedCount.value,
        'failed': failedCount.value,
        'skipped': skippedCount.value,
        'duration_seconds':
            DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds,
      },
      'steps': steps.map((step) => {
        'code': step.code,
        'attribute': step.functionAttribute?.dbCode ?? step.code,
        'title': step.title,
        'status': step.status.name,
        if (step.note != null && step.note!.isNotEmpty) 'note': step.note,
        if (step.executionTime != null)
          'elapsed_ms': step.executionTime!.inMilliseconds,
      }).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('[TestRunner] 📥 TEST_RESULTS_RESPONSE:\n${encoder.convert(response)}');
  }

  Future<void> startWithPermissionCheck() async {
    if (Get.isRegistered<DiagnosticsHomeController>()) {
      await Get.find<DiagnosticsHomeController>().startWithPermissionCheck();
    }
  }

  void _navigateToResult() {
    final failedSteps = steps.where((s) => s.status == DiagStatus.failed).toList();
    if (score < 70 && failedSteps.isNotEmpty) {
      debugPrint('[TestRunner] Điểm kiểm định $score/100 có ${failedSteps.length} bài test không đạt -> FailedTestsWarningPage');
      Get.off(() => FailedTestsWarningPage(
        failedSteps: failedSteps,
        score: score,
      ));
    } else {
      debugPrint('[TestRunner] Hoàn tất kiểm định chức năng -> DiagnosticResultPage');
      Get.off(() => const DiagnosticResultPage());
    }
  }

  Future<void> _runPhase(DiagPhase phase) async {
    final phaseSteps = steps.where((s) => s.phase == phase).toList();
    if (phaseSteps.isEmpty) return;

    currentPhase.value = phase;
    phaseProgress.value = 0;
    phaseTotal.value = phaseSteps.length;

    final name = _phaseName(phase);
    debugPrint('\n[TestRunner] >>> [BẮT ĐẦU PHASE] $name (${phaseSteps.length} bài test)');
    DiagLogger.phaseStart(name, phaseSteps.length);

    for (final step in phaseSteps) {
      debugPrint('[TestRunner] ⏳ Đang chạy bước: [${step.code}] ${step.title}');
      step.status = DiagStatus.running;
      step.note = _getRunningNote(step.code);
      steps.refresh();

      final stopwatch = Stopwatch()..start();
      final result = await _runStepWithTimeout(step);
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final minPacingMs = DiagnosticsConstants.minStepPacingMs;
      if (elapsedMs < minPacingMs && step.kind == DiagKind.auto) {
        await Future.delayed(Duration(milliseconds: minPacingMs - elapsedMs));
      }

      _evaluateStep(step, result);
      debugPrint('[TestRunner] 🏁 Kết quả [${step.code}]: status=${step.status.name}, note=${step.note ?? "OK"} (${stopwatch.elapsedMilliseconds}ms)');
      phaseProgress.value++;
      steps.refresh();

      if (step.kind == DiagKind.auto) {
        await Future.delayed(DiagnosticsConstants.stepGapDuration);
      } else {
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }

    debugPrint('[TestRunner] <<< [HOÀN THÀNH PHASE] $name\n');
    DiagLogger.phaseComplete(
      name,
      phaseSteps.where((s) => s.status == DiagStatus.passed).length,
      phaseSteps.where((s) => s.status == DiagStatus.failed).length,
      phaseSteps.where((s) => s.status == DiagStatus.skipped).length,
    );
  }

  Future<bool> _runStepWithTimeout(DiagStep step) async {
    final stopwatch = Stopwatch()..start();
    try {
      bool result;
      if (step.kind == DiagKind.auto && step.run != null) {
        result = await step.run!().timeout(
          step.timeout,
          onTimeout: () {
            step.note = LocaleKeys.diagnostics_home_timeout_after.trans(
              namedArgs: {'seconds': '${step.timeout.inSeconds}'},
            );
            return false;
          },
        );
      } else if (step.kind == DiagKind.manual && step.interact != null) {
        result = await step.interact!();
      } else {
        step.status = DiagStatus.skipped;
        step.note = LocaleKeys.diagnostics_home_no_run_function.trans();
        return false;
      }
      step.executionTime = stopwatch.elapsed;
      return result;
    } catch (e) {
      step.executionTime = stopwatch.elapsed;
      step.note = LocaleKeys.diagnostics_home_error_generic.trans(
        namedArgs: {'error': e.toString()},
      );
      return false;
    } finally {
      stopwatch.stop();
    }
  }

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

  Future<void> restartStep(DiagStep step) async {
    if (isRunning.value) return;

    step.status = DiagStatus.running;
    step.note = null;
    steps.refresh();

    final result = await _runStepWithTimeout(step);
    _evaluateStep(step, result);
    steps.refresh();
  }

  String _getRunningNote(String code) {
    switch (code) {
      case 'wifi':
        return LocaleKeys.diagnostics_home_running_note_wifi.trans();
      case 'mobile':
        return LocaleKeys.diagnostics_home_running_note_mobile.trans();
      case 'bt':
        return LocaleKeys.diagnostics_home_running_note_bt.trans();
      case 'nfc':
        return LocaleKeys.diagnostics_home_running_note_nfc.trans();
      case 'sim':
        return LocaleKeys.diagnostics_home_running_note_sim.trans();
      case 'sensors':
        return LocaleKeys.diagnostics_home_running_note_sensors.trans();
      case 'gps':
        return LocaleKeys.diagnostics_home_running_note_gps.trans();
      case 'charge':
        return LocaleKeys.diagnostics_home_running_note_charge.trans();
      case 'wired':
        return LocaleKeys.diagnostics_home_running_note_wired.trans();
      case 'lock':
        return LocaleKeys.diagnostics_home_running_note_lock.trans();
      case 'spen':
        return LocaleKeys.diagnostics_home_running_note_spen.trans();
      case 'bio':
        return LocaleKeys.diagnostics_home_running_note_bio.trans();
      default:
        return LocaleKeys.diagnostics_home_running_note_default.trans();
    }
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
}
