import 'dart:async';
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
import '../views/advanced_camera_test_page.dart';
import '../views/earpiece_test_page.dart';
import '../views/mic_test_page.dart';
import '../views/speaker_test_page.dart';
import '../views/touch_grid_test_page.dart';
import '../views/screen_burnin_test_page.dart';
import '../views/auto_screen_burnin_test_page.dart';

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

  String get manufacturer => (info['osmodel']?['manufacturer'] as String?) ?? '';

  String get modelName => (info['osmodel']?['model'] as String?) ?? '';

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
    _collectInfoEarly(); // thu thập thông tin sớm để hiển thị
    _initializeEvaluator(); // Initialize rule evaluator
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Initialize the rule evaluator system
  Future<void> _initializeEvaluator() async {
    try {
      // Wait for OS info to be collected
      await Future.delayed(const Duration(milliseconds: 500));

      // Get device info
      final osInfo = info['osmodel'] as Map<String, dynamic>? ?? {};
      final deviceBrand = osInfo['brand'] as String? ?? '';
      final deviceModel = osInfo['model'] as String? ?? '';
      final devicePlatform = osInfo['platform'] as String? ?? 'android';

      // Load profile manager
      final profileManager = await ProfileManager.getInstance();
      _profile = profileManager.getProfile(deviceModel, deviceBrand);

      // Build environment
      await _updateEnvironment();

      // Create evaluator
      _evaluator = await RuleEvaluator.create(
        profile: _profile!,
        environment: _environment,
      );

      print('✅ Rule evaluator initialized for: ${_profile?.name}');
    } catch (e) {
      print('⚠️ Failed to initialize evaluator: $e');
      // Use default profile
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
      // Ưu tiên kiểm tra OS/Model trước tiên để biết nền tảng & hãng
      DiagStep(
        code: 'osmodel',
        title: 'OS/Model',
        kind: DiagKind.auto,
        run: _snapOsModel,
      ),

      // Info/auto checks
      DiagStep(
        code: 'battery',
        title: 'Pin & Sạc',
        kind: DiagKind.auto,
        run: _snapBattery,
      ),
      DiagStep(
        code: 'mobile',
        title: 'Mạng di động (radio, dBm)',
        kind: DiagKind.auto,
        run: _snapMobile,
      ),
      DiagStep(
        code: 'wifi',
        title: 'Wi-Fi (SSID)',
        kind: DiagKind.auto,
        run: _snapWifi,
      ),

      // NEW: RAM/ROM
      DiagStep(
        code: 'ram',
        title: 'RAM (free/total)',
        kind: DiagKind.auto,
        run: _snapRam,
      ),
      DiagStep(
        code: 'rom',
        title: 'ROM (free/total)',
        kind: DiagKind.auto,
        run: _snapRom,
      ),

      DiagStep(
        code: 'bt',
        title: 'Bluetooth (scan)',
        kind: DiagKind.auto,
        run: _checkBluetooth,
      ),
      DiagStep(code: 'nfc', title: 'NFC', kind: DiagKind.auto, run: _snapNfc),
      DiagStep(
        code: 'sim',
        title: 'SIM (slot/trạng thái)',
        kind: DiagKind.auto,
        run: _snapSim,
      ),
      DiagStep(
        code: 'sensors',
        title: 'Cảm biến (accel/gyro)',
        kind: DiagKind.auto,
        run: _snapSensors,
      ),
      DiagStep(
        code: 'gps',
        title: 'GPS (accuracy)',
        kind: DiagKind.auto,
        run: _snapGps,
      ),
      DiagStep(
        code: 'charge',
        title: 'Nguồn sạc (USB/AC/Wireless)',
        kind: DiagKind.auto,
        run: _snapCharging,
      ),
      DiagStep(
        code: 'wired',
        title: 'Tai nghe có dây',
        kind: DiagKind.auto,
        run: _snapWiredHeadset,
      ),
      DiagStep(
        code: 'lock',
        title: 'Màn hình khoá',
        kind: DiagKind.auto,
        run: _snapScreenLock,
      ),
      DiagStep(
        code: 'spen',
        title: 'S-Pen (Samsung)',
        kind: DiagKind.auto,
        run: _snapSPen,
      ),
      DiagStep(
        code: 'bio',
        title: 'Sinh trắc (khả dụng)',
        kind: DiagKind.auto,
        run: _snapBiometrics,
      ),

      // Interactive/manual
      DiagStep(
        code: 'vibrate',
        title: 'Rung',
        kind: DiagKind.auto,
        run: _testVibration,
      ),
      DiagStep(
        code: 'keys',
        title: 'Phím vật lý (xác nhận)',
        kind: DiagKind.manual,
        interact: _confirm(
          'Nhấn phím Âm lượng và Nguồn — hoạt động bình thường?',
        ),
      ),
      DiagStep(
        code: 'touch',
        title: 'Cảm ứng full màn',
        kind: DiagKind.manual,
        interact: _openTouchGrid,
      ),
      DiagStep(
        code: 'screen',
        title: 'Sọc ám màn hình',
        kind: DiagKind.manual,
        interact: _openScreenBurnInTest,
      ),
      DiagStep(
        code: 'camera',
        title: 'Camera trước/sau',
        kind: DiagKind.manual,
        interact: _openCameraQuick,
      ),
      DiagStep(
        code: 'speaker',
        title: 'Loa ngoài (beep)',
        kind: DiagKind.manual,
        interact: _openSpeakerTest,
      ),
      DiagStep(
        code: 'mic',
        title: 'Micro (amplitude)',
        kind: DiagKind.manual,
        interact: _openMicTest,
      ),
      DiagStep(
        code: 'ear',
        title: 'Loa trong (proximity)',
        kind: DiagKind.manual,
        interact: _openEarpieceTest,
      ),
    ];
  }

  Future<void> _prepareCameras() async {
    try {
      _cams = await availableCameras();

      // Store camera info
      final front = _cams.where((c) => c.lensDirection == CameraLensDirection.front).toList();
      final back = _cams.where((c) => c.lensDirection == CameraLensDirection.back).toList();

      final cameraInfo = {
        'total': _cams.length,
        'front': front.length,
        'back': back.length,
        'cameras': _cams.map((c) => {
          'name': c.name,
          'direction': c.lensDirection.toString().split('.').last,
          'sensorOrientation': c.sensorOrientation,
        }).toList(),
      };

      info['camera_specs'] = cameraInfo;
    } catch (_) {
      info['camera_specs'] = {'total': 0, 'front': 0, 'back': 0, 'cameras': []};
    }
  }

  // ==== header info preload (gọi song song) ====
  Future<void> _collectInfoEarly() async {
    try {
      final results = await Future.wait<Map<String, dynamic>>([
        _getBatteryInfo(),
        _getOsAndModel(),
        _getWifiInfo(),
        _getRamInfo(), // NEW
        _getRomInfo(), // NEW
      ]);
      info.addAll({
        'battery': results[0],
        'osmodel': results[1],
        'wifi': results[2],
        'ram': results[3], // NEW
        'rom': results[4], // NEW
      });
    } catch (_) {
      // bỏ qua nếu bất kỳ cái nào lỗi
    }
  }

  // ================== RUN FLOW ==================
  Future<void> start() async {
    if (isRunning.value) return;
    isRunning.value = true;
    passedCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;

    // Ensure evaluator is ready
    if (_evaluator == null) {
      await _initializeEvaluator();
    }

    // Update environment before running tests
    await _updateEnvironment();

    for (final s in steps) {
      s.status = DiagStatus.running;
      steps.refresh();

      bool runSuccess = false;
      try {
        // Execute the test
        if (s.kind == DiagKind.auto && s.run != null) {
          runSuccess = await s.run!();
        } else if (s.kind == DiagKind.manual && s.interact != null) {
          runSuccess = await s.interact!();
        } else {
          s.status = DiagStatus.skipped;
          s.note = 'Không có hàm thực thi';
          skippedCount.value++;
          steps.refresh();
          continue;
        }
      } catch (e) {
        s.note = 'Lỗi: ${e.toString()}';
        s.status = DiagStatus.failed;
        failedCount.value++;
        steps.refresh();
        continue;
      }

      // Evaluate result using rule evaluator
      if (_evaluator != null && info[s.code] != null) {
        final payload = info[s.code] is Map
            ? (info[s.code] as Map).cast<String, dynamic>()
            : {'value': info[s.code]};

        final evalResult = _evaluator!.evaluate(s.code, payload);
        final reason = _evaluator!.getReason(s.code, payload, evalResult);

        switch (evalResult) {
          case EvalResult.pass:
            s.status = DiagStatus.passed;
            s.note = reason;
            passedCount.value++;
            break;
          case EvalResult.fail:
            s.status = DiagStatus.failed;
            s.note = reason;
            failedCount.value++;
            break;
          case EvalResult.skip:
            s.status = DiagStatus.skipped;
            s.note = reason;
            skippedCount.value++;
            break;
        }
      } else {
        // Fallback to simple pass/fail based on run result
        if (runSuccess) {
          s.status = DiagStatus.passed;
          passedCount.value++;
        } else {
          s.status = DiagStatus.failed;
          failedCount.value++;
        }
      }

      steps.refresh();
    }

    isRunning.value = false;

    final total = steps.length;
    final score = (passedCount.value * 100 / total).round();
    final grade =
        (score >= 90)
            ? 'Loại 1'
            : (score >= 75)
            ? 'Loại 2'
            : (score >= 60)
            ? 'Loại 3'
            : (score >= 40)
            ? 'Loại 4'
            : 'Loại 5';
    Get.snackbar(
      'Kết quả kiểm định',
      'Điểm: $score • $grade',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // ================== PRINT TEST RESULTS ==================
  /// Prints detailed test results to console
  void printTestResults() {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║           KẾT QUẢ KIỂM ĐỊNH THIẾT BỊ                      ║');
    print('╚════════════════════════════════════════════════════════════╝\n');

    // Device Information
    print('📱 THÔNG TIN THIẾT BỊ:');
    print('   ├─ Model: ${modelName.isNotEmpty ? modelName : "Không xác định"}');
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
    final completed = passedCount.value + failedCount.value + skippedCount.value;
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
      print('   ${isLast ? "  " : "│"}     Type: ${step.kind == DiagKind.auto ? "Auto" : "Manual"}');

      if (step.note != null && step.note!.isNotEmpty) {
        print('   ${isLast ? "  " : "│"}     Note: ${step.note}');
      }

      if (!isLast) print('   │');
    }

    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║  Generated: ${DateTime.now().toString().split('.')[0]}   ║');
    print('╚════════════════════════════════════════════════════════════╝\n');
  }

  // Helper method to convert bytes to GiB
  int? _toGiB(dynamic v) {
    if (v is! num) return null;
    const giB = 1024 * 1024 * 1024;
    return (v.toDouble() / giB).round();
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
    return true;
  }

  Future<bool> _snapMobile() async {
    info['mobile'] = await _getMobileNetworkInfo();
    return true;
  }

  Future<bool> _snapWifi() async {
    info['wifi'] = await _getWifiInfo();
    return true;
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

  Future<Map<String, dynamic>> _getOsAndModel() async {
    try {
      final a = await _deviceInfo.androidInfo;
      final vendor =
          (a.manufacturer?.toLowerCase() ?? a.brand?.toLowerCase() ?? '');
      return {
        'platform': 'android',
        'sdk': a.version.sdkInt,
        'release': a.version.release,
        'model': a.model,
        'brand': a.brand,
        'manufacturer': a.manufacturer,
        'vendor': vendor, // normalized brand/manufacturer
        'isSamsung': vendor == 'samsung',
        'isApple': false,
      };
    } catch (_) {
      try {
        final i = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'systemVersion': i.systemVersion,
          'model': i.utsname.machine,
          'name': i.name,
          'brand': 'Apple',
          'manufacturer': 'Apple',
          'vendor': 'apple',
          'isSamsung': false,
          'isApple': true,
        };
      } catch (_) {
        return {'platform': 'unknown'};
      }
    }
  }

  Future<Map<String, dynamic>> _getMobileNetworkInfo() async {
    final conn = await Connectivity().checkConnectivity();
    final onMobile = conn.contains(ConnectivityResult.mobile);
    int? dbm;
    String? radio;
    if (onMobile) {
      dbm = await _invoke<int>('getSignalStrengthDbm');
      radio = await _invoke<String>('getMobileRadioType');
    }
    return {'connected': onMobile, 'dbm': dbm, 'radio': radio};
  }

  Future<Map<String, dynamic>> _getWifiInfo() async {
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
    return {'connected': onWifi, 'ssid': ssid};
  }

  // ===== NEW: RAM & ROM via MethodChannel =====
  Map<String, dynamic> _normalizeBytesMap(Map? m) {
    final free =
        (m?['freeBytes'] is num) ? (m?['freeBytes'] as num).toInt() : null;
    final total =
        (m?['totalBytes'] is num) ? (m?['totalBytes'] as num).toInt() : null;
    return {'freeBytes': free, 'totalBytes': total};
  }

  Future<Map<String, dynamic>> _getRamInfo() async {
    try {
      final Map? raw = await _invoke<Map>('getRamInfo');
      return _normalizeBytesMap(raw);
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null};
    }
  }

  Future<Map<String, dynamic>> _getRomInfo() async {
    try {
      final Map? raw = await _invoke<Map>('getRomInfo');
      return _normalizeBytesMap(raw);
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null};
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
    final slots = await _invoke<int>('getSimSlotCount');
    final states = await _invoke<List<dynamic>>('getSimStates');
    return {'slotCount': slots, 'states': states};
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
      await Vibration.vibrate(duration: 250);
      await Future.delayed(const Duration(milliseconds: 300));
      await Vibration.vibrate(pattern: [0, 120, 80, 120]);
      return true;
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

  Future<bool> _openScreenBurnInTest() async {
    // Tier 5 (máy cũ/giá thấp) → tự động test
    if (_profile?.shouldAutoTestScreen == true) {
      return (await Get.to<bool>(() => const AutoScreenBurnInTestPage())) == true;
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
      final ok = await Get.to<bool>(() => AdvancedCameraTestPage(cameras: _cams));
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
}
