import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import 'package:kdtd_ver2_1/app/data/model/device_cosmetic_survey.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/services/device_hardware_service.dart';
import 'package:kdtd_ver2_1/app/data/services/diag_logger.dart';
import 'package:kdtd_ver2_1/app/data/services/diagnostic_grade_service.dart';
import 'package:kdtd_ver2_1/app/data/services/phone_info_service.dart';
import 'package:kdtd_ver2_1/app/modules/question_check/question_check_controller.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';

/// DiagnosticsHomeController - Điều phối màn hình tổng quan và thông số thiết bị trang chủ.
/// Logic quét phần cứng native đã được chuyển sang [DeviceHardwareService],
/// và logic thực thi bài test chức năng đã được chuyển sang [TestRunnerController].
class DiagnosticsHomeController extends GetxController {
  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final info = <String, dynamic>{}.obs;
  final isRunning = false.obs;
  final cosmeticSurvey = DeviceCosmeticSurvey().obs;

  final serialNumber = ''.obs;
  final isUpgradeEligible = false.obs;

  // ==================== THÔNG TIN THIẾT BỊ (DỮ LIỆU TỔNG HỢP) ====================
  Map<String, dynamic>? get _osModel =>
      info['osmodel'] as Map<String, dynamic>?;

  bool get isAndroid => _osModel?['platform'] == 'android';
  bool get isIOS => _osModel?['platform'] == 'ios';
  String get platform => (_osModel?['platform'] as String?) ?? 'unknown';
  String get vendor => (_osModel?['vendor'] as String?) ?? '';
  String get brand => (_osModel?['brand'] as String?) ?? '';
  String get manufacturer => (_osModel?['manufacturer'] as String?) ?? '';
  String get modelName => (_osModel?['model'] as String?) ?? '';
  String get marketingName => (_osModel?['marketingName'] as String?) ?? '';
  String get deviceId => (_osModel?['deviceId'] as String?) ?? '';
  /// RAM/ROM làm tròn LÊN mốc phổ biến (GB), null nếu không đọc được.
  int? get ramGbValue =>
      roundUpToStandardGb(info['ram']?['totalBytes'], standardRamGb);
  int? get romGbValue =>
      roundUpToStandardGb(info['rom']?['totalBytes'], standardRomGb);
  String get ramGb => _gbLabel(ramGbValue);
  String get romGb => _gbLabel(romGbValue);
  String get itCode {
    final model = modelName.trim();
    final ram = ramGb.replaceAll(' ', '');
    final rom = romGb.replaceAll(' ', '');
    if (model.isEmpty) return '';
    return '${model}_${ram}_$rom';
  }
  int? get batteryLevel => info['battery']?['level'] as int?;
  bool get isWifiConnected => info['wifi']?['connected'] == true;
  bool get isSamsung => vendor.toLowerCase() == 'samsung';
  bool get isApple => vendor.toLowerCase() == 'apple' || isIOS;

  @override
  void onInit() {
    super.onInit();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    debugPrint('[DiagnosticsHome] Khởi tạo DiagnosticsHomeController...');
    DiagLogger.log('Starting initialization sequence...');
    await _collectDeviceInfoSafe();
  }

  /// Thu thập thông tin cấu hình ban đầu an toàn
  Future<void> _collectDeviceInfoSafe() async {
    try {
      final osInfo = await DeviceHardwareService.getOsAndModel(
        onMarketingNameFetched: (name) {
          if (info['osmodel'] != null && name.isNotEmpty) {
            (info['osmodel'] as Map)['marketingName'] = name;
            info.refresh();
          }
        },
      );
      info['osmodel'] = osInfo;

      // Mỗi nguồn tự bắt lỗi riêng: pin/Wi-Fi lỗi (vd simulator không có pin)
      // không được kéo theo mất RAM/ROM như khi gom chung một Future.wait.
      final results = await Future.wait([
        _collect('battery', DeviceHardwareService.getBatteryInfo),
        _collect('wifi', DeviceHardwareService.getWifiInfo),
        _collect('ram', DeviceHardwareService.getRamInfo),
        _collect('rom', DeviceHardwareService.getRomInfo),
      ]);
      for (final (i, key) in ['battery', 'wifi', 'ram', 'rom'].indexed) {
        final value = results[i];
        if (value != null) info[key] = value;
      }
      info['it_code'] = itCode;

      _logDeviceSummary();
    } catch (e, stack) {
      debugPrint('[DiagnosticsHome] Lỗi nghiêm trọng khi quét thiết bị: $e');
      DiagLogger.error(
        'init',
        'Lỗi nghiêm trọng khi thu thập thông tin thiết bị: $e',
      );
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<Map<String, dynamic>?> _collect(
    String label,
    Future<Map<String, dynamic>> Function() read,
  ) async {
    try {
      return await read();
    } catch (e) {
      debugPrint('[DiagnosticsHome] Không đọc được $label: $e');
      DiagLogger.warning('init', 'Không đọc được $label: $e');
      return null;
    }
  }

  void _logDeviceSummary() {
    final response = {
      'status': 'success',
      'device_id': deviceId,
      'it_code': itCode,
      'marketing_name': marketingName.isNotEmpty ? marketingName : modelName,
      'brand': brand,
      'model': modelName,
      'platform': platform,
      'ram': ramGb,
      'rom': romGb,
      'wifi': info['wifi']?['connected'] == true
          ? {
              'connected': true,
              'ssid': info['wifi']?['ssid'],
              'ip': info['wifi']?['ip'],
            }
          : {'connected': false},
    };

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('[DiagnosticsHome] DEVICE_INFO_RESPONSE:\n${encoder.convert(response)}');
  }

  // Hệ điều hành báo thấp hơn dung lượng ghi trên hộp (máy 8GB → ~7.4 GiB,
  // ROM 128GB → ~110 GiB vì phân vùng /data) nên làm tròn LÊN mốc gần nhất.
  // RAM và ROM có bộ mốc riêng: dùng chung sẽ ra "24 GB" cho máy ROM 32GB.
  static const standardRamGb = [1, 2, 3, 4, 6, 8, 10, 12, 16, 18, 24, 32];
  static const standardRomGb = [8, 16, 32, 64, 128, 256, 512, 1024, 2048];

  @visibleForTesting
  static int? roundUpToStandardGb(dynamic bytes, List<int> sizes) {
    if (bytes is! num || bytes <= 0) return null;
    const giB = 1024 * 1024 * 1024;
    final gb = bytes / giB;
    return sizes.firstWhere((s) => s >= gb, orElse: () => gb.ceil());
  }

  String _gbLabel(int? gb) => gb == null ? 'N/A' : '$gb GB';

  // ==================== QUY TRÌNH HÀNH ĐỘNG KIỂM ĐỊNH ====================

  /// Luôn chuyển sang màn hình nhập serial trước, trừ khi đã kiểm tra xong.
  Future<void> startWithPermissionCheck() async {
    if (isRunning.value) return;

    if (isUpgradeEligible.value) {
      debugPrint('[DiagnosticsHome] Bỏ qua nhập serial do đã nhập đúng trước đó...');
      Get.toNamed(AppRoutes.permissionCheck);
      return;
    }

    debugPrint('[DiagnosticsHome] Chuyển sang module màn hình nhập serial...');
    Get.toNamed(AppRoutes.serialCheck);
  }

  /// Quét thông tin cơ bản rồi vào thẳng Function Check (Test Runner).
  /// Luồng: Home -> PermissionCheck -> TestRunner -> QuestionCheck -> Result.
  /// KHÔNG còn đi qua DeviceSpecsConfirmation/PreTestGuide (đã bỏ khỏi luồng
  /// theo yêu cầu; 2 module đó vẫn giữ nguyên code, chỉ không điều hướng tới).
  Future<void> startCriticalScanAndConfirm() async {
    if (isRunning.value) return;

    debugPrint('[DiagnosticsHome] Bắt đầu quét thông số cơ bản...');
    isRunning.value = true;
    await _collectDeviceInfoSafe();
    isRunning.value = false;

    // Đảm bảo TestRunnerController được khởi tạo và nhận info ban đầu để chạy Function Check
    debugPrint('[DiagnosticsHome] Khởi tạo TestRunnerController và bắt đầu Function Check...');
    final testRunner = Get.isRegistered<TestRunnerController>()
        ? Get.find<TestRunnerController>()
        : Get.put(TestRunnerController(), permanent: true);
    testRunner.setInitialInfo(info);

    Get.toNamed(AppRoutes.testRunner);
  }

  /// Chuyển tiếp sang TestRunnerController nếu có component gọi
  Future<void> startFunctionalDiagnostics() async {
    if (Get.isRegistered<TestRunnerController>()) {
      await Get.find<TestRunnerController>().startFunctionalDiagnostics();
    }
  }

  // ==================== ỦY THÁC TƯƠNG THÍCH ====================
  TestRunnerController? get _runner =>
      Get.isRegistered<TestRunnerController>()
          ? Get.find<TestRunnerController>()
          : null;

  List<DiagStep> get steps => _runner?.steps ?? <DiagStep>[];
  int get total => _runner?.total ?? 0;
  int get completed => _runner?.completed ?? 0;
  int get score => _runner?.score ?? 0;
  String get grade => _runner?.grade ?? '';
  RxInt get passedCount => _runner?.passedCount ?? 0.obs;
  RxInt get failedCount => _runner?.failedCount ?? 0.obs;
  RxInt get skippedCount => _runner?.skippedCount ?? 0.obs;

  int get questionCheckType {
    if (Get.isRegistered<QuestionCheckController>()) {
      return Get.find<QuestionCheckController>().overallType;
    }
    return 1;
  }

  int get finalDeviceType {
    return DiagnosticGradeService.finalType(
      hasFunctionCheckFailed: failedCount.value > 0,
      questionCheckType: questionCheckType,
    );
  }

  void printTestResults() {
    _runner?.printTestResults();
  }

  Future<void> restartStep(DiagStep step) async {
    if (_runner != null) {
      await _runner!.restartStep(step);
    }
  }

  // ==================== API THÔNG TIN THIẾT BỊ ====================
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
