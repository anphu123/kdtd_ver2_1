import 'dart:async';
import 'dart:io';
import 'dart:ui' show Offset;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/camera_test_constants.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// ============================================================
/// CameraTestController - Quản lý kiểm tra tất cả camera trên máy
/// ============================================================
///
/// Hỗ trợ kiểm tra mọi cảm biến camera có trên thiết bị:
/// - Duyệt qua từng camera trong danh sách [cameras]
/// - Live Preview thời gian thực
/// - Chụp ảnh thử nghiệm (Capture test)
/// - Lấy nét tự động / Chạm để lấy nét (Auto-focus test)
/// - Đèn flash trợ sáng (Flash torch test)
/// - Giám sát cảm biến con quay hồi chuyển (OIS/EIS Stabilization)
class CameraTestController extends GetxController {
  CameraTestController({required this.cameras});

  final List<CameraDescription> cameras;

  // ==================== REACTIVE STATE ====================
  final controller = Rx<CameraController?>(null);
  final currentCameraIndex = 0.obs;
  final isInitializing = false.obs;
  final testedCameras = <int>{}.obs;

  final hasStabilization = false.obs;
  final cameraWarning = Rx<String?>(null);
  final isOriginal = true.obs;
  final capturedImagePath = Rx<String?>(null);
  final isFlashOn = false.obs;

  CameraDescription? get currentCamera =>
      (cameras.isNotEmpty && currentCameraIndex.value < cameras.length)
          ? cameras[currentCameraIndex.value]
          : null;

  bool get isReady => controller.value?.value.isInitialized == true;
  int get totalCameras => cameras.length;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _maxGyro = 0.0;
  final List<double> _gyroHistory = [];

  @override
  void onInit() {
    super.onInit();
    debugPrint('[CameraTest] Khởi tạo bài test camera với ${cameras.length} camera:');
    for (int i = 0; i < cameras.length; i++) {
      final c = cameras[i];
      debugPrint('[CameraTest]  - Cam #$i: name=${c.name}, lens=${c.lensDirection}');
    }
    _verifyCameraConfiguration();
    _startGyroMonitoring();
    if (cameras.isNotEmpty) {
      _openCamera(cameras[currentCameraIndex.value]);
    }
  }

  @override
  void onClose() {
    _gyroSub?.cancel();
    _disposeCameraSync();
    _cleanupCapturedImage();
    super.onClose();
  }

  // ==================== SETUP ====================
  void _verifyCameraConfiguration() {
    final total = cameras.length;
    if (total == 0) {
      cameraWarning.value = LocaleKeys.camera_test_error_no_camera_detected.trans();
      isOriginal.value = false;
    }
  }

  void _startGyroMonitoring() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      final magnitude =
          event.x * event.x + event.y * event.y + event.z * event.z;
      if (magnitude > _maxGyro) _maxGyro = magnitude;

      _gyroHistory.add(magnitude);
      if (_gyroHistory.length > CameraTestConstants.gyroHistoryMaxLength) {
        _gyroHistory.removeAt(0);
      }

      if (hasStabilization.value ||
          _gyroHistory.length < CameraTestConstants.gyroHistoryMinSamples) {
        return;
      }

      final avg = _gyroHistory.reduce((a, b) => a + b) / _gyroHistory.length;
      final variance =
          _gyroHistory
              .map((v) => (v - avg) * (v - avg))
              .reduce((a, b) => a + b) /
          _gyroHistory.length;

      if (variance < CameraTestConstants.gyroVarianceThreshold &&
          _maxGyro > CameraTestConstants.gyroMagnitudeThreshold) {
        hasStabilization.value = true;
      }
    });
  }

  // ==================== CAMERA LIFECYCLE ====================
  Future<void> _openCamera(CameraDescription camera) async {
    isInitializing.value = true;
    capturedImagePath.value = null;
    isFlashOn.value = false;
    await _disposeCameraSync();

    final cam = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cam.initialize();
      controller.value = cam;
      isInitializing.value = false;
      debugPrint(
        '[CameraTest] Mở thành công Camera #${currentCameraIndex.value} (${camera.name}, ${camera.lensDirection})',
      );
    } catch (e) {
      isInitializing.value = false;
      debugPrint('[CameraTest] Lỗi khởi tạo Camera #${currentCameraIndex.value}: $e');
      Get.snackbar(
        LocaleKeys.camera_test_error_title.trans(),
        LocaleKeys.camera_test_error_init_camera.trans(namedArgs: {'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> switchCamera(int index) async {
    if (index < 0 || index >= cameras.length) return;
    if (index == currentCameraIndex.value && controller.value != null) return;
    currentCameraIndex.value = index;
    await _openCamera(cameras[index]);
  }

  Future<void> nextCamera() async {
    if (cameras.isEmpty) return;
    final nextIdx = (currentCameraIndex.value + 1) % cameras.length;
    await switchCamera(nextIdx);
  }

  // ==================== TESTS: CHỤP ẢNH, FOCUS, FLASH ====================
  Future<void> captureTest() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      await _cleanupCapturedImage();
      final image = await cam.takePicture();
      capturedImagePath.value = image.path;
      testedCameras.add(currentCameraIndex.value);
      debugPrint('[CameraTest] Chụp ảnh thành công: ${image.path}');

      Get.snackbar(
        '',
        LocaleKeys.camera_test_capture_success.trans(),
        snackPosition: SnackPosition.BOTTOM,
        duration: CameraTestConstants.actionSuccessSnackbarDuration,
      );
    } catch (e) {
      debugPrint('[CameraTest] Lỗi chụp ảnh: $e');
      Get.snackbar(
        LocaleKeys.camera_test_error_title.trans(),
        LocaleKeys.camera_test_capture_error.trans(namedArgs: {'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testFocus([Offset? point]) async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      final previewSize = cam.value.previewSize!;
      final focusPoint = point ?? Offset(previewSize.width / 2, previewSize.height / 2);
      await cam.setFocusPoint(focusPoint);
      await cam.setFocusMode(FocusMode.auto);

      Get.snackbar(
        '',
        LocaleKeys.camera_test_focus_success.trans(),
        snackPosition: SnackPosition.BOTTOM,
        duration: CameraTestConstants.actionSuccessSnackbarDuration,
      );
    } catch (e) {
      debugPrint('[CameraTest] Lỗi lấy nét: $e');
      Get.snackbar(
        '',
        LocaleKeys.camera_test_focus_unavailable.trans(namedArgs: {'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testFlash() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      if (isFlashOn.value) {
        await cam.setFlashMode(FlashMode.off);
        isFlashOn.value = false;
      } else {
        await cam.setFlashMode(FlashMode.torch);
        isFlashOn.value = true;
        Future.delayed(CameraTestConstants.flashTorchDuration, () async {
          try {
            await cam.setFlashMode(FlashMode.off);
            isFlashOn.value = false;
          } catch (_) {}
        });
      }

      Get.snackbar(
        '',
        LocaleKeys.camera_test_flash_success.trans(),
        snackPosition: SnackPosition.BOTTOM,
        duration: CameraTestConstants.actionSuccessSnackbarDuration,
      );
    } catch (e) {
      debugPrint('[CameraTest] Lỗi bật đèn flash: $e');
      Get.snackbar(
        '',
        LocaleKeys.camera_test_flash_unavailable.trans(namedArgs: {'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== WORKFLOW ====================
  void confirmCurrentCamera() {
    testedCameras.add(currentCameraIndex.value);
    debugPrint('[CameraTest] Xác nhận Camera #${currentCameraIndex.value} hoạt động tốt.');

    final untested = <int>[];
    for (int i = 0; i < cameras.length; i++) {
      if (!testedCameras.contains(i)) untested.add(i);
    }

    if (untested.isNotEmpty) {
      debugPrint('[CameraTest] Chuyển tiếp tới Camera chưa test: #${untested.first}');
      switchCamera(untested.first);
    } else {
      debugPrint('[CameraTest] Toàn bộ ${cameras.length} camera đã được kiểm tra đạt chuẩn!');
      finish(true);
    }
  }

  void skipCamera() {
    if (currentCameraIndex.value + 1 < cameras.length) {
      switchCamera(currentCameraIndex.value + 1);
    } else {
      finish(testedCameras.isNotEmpty);
    }
  }

  void finish(bool passed) {
    _disposeCameraSync();
    Get.back(result: passed);
  }

  // ==================== CLEANUP ====================
  Future<void> _disposeCameraSync() async {
    final cam = controller.value;
    if (cam == null) return;
    try {
      try {
        await cam.stopImageStream();
      } catch (_) {}
      await cam.dispose();
    } catch (_) {}
    controller.value = null;
  }

  Future<void> _cleanupCapturedImage() async {
    final path = capturedImagePath.value;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    capturedImagePath.value = null;
  }
}
