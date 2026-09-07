import 'dart:async';
import 'dart:io';
import 'dart:ui' show Offset;

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// ============================================================
/// CameraTestController - Logic Bài Test Camera
/// ============================================================
///
/// Mở camera theo từng bước (trước → sau → chụp → focus → flash), theo dõi
/// con quay hồi chuyển để phát hiện chống rung OIS/EIS, và báo kết quả về
/// qua `Get.back(result: passed)`.
class CameraTestController extends GetxController {
  CameraTestController({required this.cameras});

  final List<CameraDescription> cameras;

  // ==================== REACTIVE STATE ====================
  final controller = Rx<CameraController?>(null);
  final currentStep = 0.obs;
  final isInitializing = false.obs;

  final frontCameraTested = false.obs;
  final backCameraTested = false.obs;
  final captureTested = false.obs;
  final focusTested = false.obs;
  final flashTested = false.obs;

  final hasStabilization = false.obs;
  final cameraWarning = Rx<String?>(null);
  final isOriginal = true.obs;
  final capturedImagePath = Rx<String?>(null);
  final totalCameras = 0.obs;

  bool get isReady => controller.value?.value.isInitialized == true;

  CameraDescription? _frontCamera;
  CameraDescription? _backCamera;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _maxGyro = 0.0;
  final List<double> _gyroHistory = [];

  @override
  void onInit() {
    super.onInit();
    _categorizeCamera();
    _verifyCameraConfiguration();
    _startGyroMonitoring();
    _startCurrentStep();
  }

  @override
  void onClose() {
    _gyroSub?.cancel();
    _disposeCameraSync();
    _cleanupCapturedImage();
    super.onClose();
  }

  // ==================== SETUP ====================

  void _categorizeCamera() {
    for (final cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        _frontCamera ??= cam;
      } else if (cam.lensDirection == CameraLensDirection.back) {
        _backCamera ??= cam;
      }
    }
  }

  void _verifyCameraConfiguration() {
    final total = cameras.length;
    final frontCount =
        cameras.where((c) => c.lensDirection == CameraLensDirection.front).length;
    final backCount =
        cameras.where((c) => c.lensDirection == CameraLensDirection.back).length;

    totalCameras.value = total;

    if (total == 1) {
      cameraWarning.value = '⚠️ Chỉ có 1 camera';
      isOriginal.value = false;
    } else if (total == 2) {
      if (frontCount != 1 || backCount != 1) {
        cameraWarning.value = '⚠️ Cấu hình camera bất thường';
        isOriginal.value = false;
      }
    } else if (total >= 3 && total <= 5) {
      if (frontCount < 1 || backCount < 2) {
        cameraWarning.value = '⚠️ Số lượng camera không cân đối';
        isOriginal.value = false;
      }
    } else if (total > 5) {
      cameraWarning.value = '⚠️ Quá nhiều camera ($total)';
      isOriginal.value = false;
    } else {
      cameraWarning.value = '❌ Không phát hiện camera';
      isOriginal.value = false;
    }
  }

  void _startGyroMonitoring() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      final magnitude = event.x * event.x + event.y * event.y + event.z * event.z;
      if (magnitude > _maxGyro) _maxGyro = magnitude;

      _gyroHistory.add(magnitude);
      if (_gyroHistory.length > 50) _gyroHistory.removeAt(0);

      if (hasStabilization.value || _gyroHistory.length < 30) return;

      final avg = _gyroHistory.reduce((a, b) => a + b) / _gyroHistory.length;
      final variance =
          _gyroHistory.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) /
              _gyroHistory.length;

      if (variance < 0.5 && _maxGyro > 2.0) {
        hasStabilization.value = true;
      }
    });
  }

  // ==================== STEP FLOW ====================

  Future<void> _startCurrentStep() async {
    CameraDescription? camera;
    switch (currentStep.value) {
      case 0:
        camera = _frontCamera;
        break;
      case 1:
      case 2:
      case 3: // focus test
      case 4: // flash test
        camera = _backCamera;
        break;
    }

    if (camera == null) {
      nextStep();
      return;
    }
    await _openCamera(camera);
  }

  Future<void> _openCamera(CameraDescription camera) async {
    isInitializing.value = true;
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
    } catch (e) {
      isInitializing.value = false;
      Get.snackbar('Lỗi', 'Lỗi khởi tạo camera: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Chuyển sang bước kế tiếp; ở bước cuối thì kết thúc bài test (pass).
  void nextStep() {
    switch (currentStep.value) {
      case 0:
        frontCameraTested.value = true;
        currentStep.value = 1;
        _startCurrentStep();
        break;
      case 1:
        backCameraTested.value = true;
        currentStep.value = 2;
        _startCurrentStep();
        break;
      case 2:
        captureTested.value = true;
        currentStep.value = 3;
        _startCurrentStep();
        break;
      case 3:
        focusTested.value = true;
        currentStep.value = 4;
        _startCurrentStep();
        break;
      case 4:
        flashTested.value = true;
        finish(true);
        break;
    }
  }

  void skipStep() => nextStep();

  void finish(bool passed) => Get.back(result: passed);

  // ==================== TESTS ====================

  Future<void> captureTest() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      await _cleanupCapturedImage();
      final image = await cam.takePicture();
      capturedImagePath.value = image.path;

      Get.snackbar('', '✓ Chụp thành công',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));

      Future.delayed(const Duration(seconds: 2), nextStep);
    } catch (e) {
      Get.snackbar('Lỗi', '✗ Lỗi chụp: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> testFocus() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      final previewSize = cam.value.previewSize!;
      final center = Offset(previewSize.width / 2, previewSize.height / 2);
      await cam.setFocusPoint(center);
      await cam.setFocusMode(FocusMode.auto);

      Get.snackbar('', '✓ Focus hoạt động',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      Future.delayed(const Duration(seconds: 2), nextStep);
    } catch (e) {
      Get.snackbar('', 'Focus không khả dụng: $e', snackPosition: SnackPosition.BOTTOM);
      nextStep();
    }
  }

  Future<void> testFlash() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      await cam.setFlashMode(FlashMode.torch);
      await Future.delayed(const Duration(seconds: 1));
      await cam.setFlashMode(FlashMode.off);

      Get.snackbar('', '✓ Flash hoạt động',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
      Future.delayed(const Duration(seconds: 1), nextStep);
    } catch (e) {
      Get.snackbar('', 'Flash không khả dụng: $e', snackPosition: SnackPosition.BOTTOM);
      nextStep();
    }
  }

  // ==================== CLEANUP ====================

  Future<void> _disposeCameraSync() async {
    final cam = controller.value;
    if (cam == null) return;
    try {
      try {
        await cam.stopImageStream();
      } catch (_) {
        // Image stream có thể chưa từng bật, bỏ qua.
      }
      await cam.dispose();
    } catch (_) {
      // Bỏ qua lỗi khi dọn dẹp controller cũ.
    }
  }

  Future<void> _cleanupCapturedImage() async {
    final path = capturedImagePath.value;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Bỏ qua lỗi dọn file tạm.
    }
    capturedImagePath.value = null;
  }
}
