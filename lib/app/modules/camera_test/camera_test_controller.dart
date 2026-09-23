import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/camera_test_constants.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// ============================================================
/// CameraTestController - Quản lý kiểm tra tất cả camera trên máy
/// ============================================================
///
/// Hỗ trợ kiểm tra mọi cảm biến camera có trên thiết bị một cách TỰ ĐỘNG:
/// - Duyệt qua từng camera trong danh sách [cameras]
/// - Live Preview thời gian thực
/// - Chụp ảnh tự động (Auto Capture) sau một khoảng thời gian
/// - Tự động phát hiện ảnh đen (lỗi cảm biến hoặc bị che)
class CameraTestController extends GetxController {
  CameraTestController({required this.cameras});

  final List<CameraDescription> cameras;

  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final controller = Rx<CameraController?>(null);
  final currentCameraIndex = 0.obs;
  final isInitializing = false.obs;
  final isAutoCapturing = false.obs;
  final cameraResults = <int, bool>{}.obs;

  final cameraWarning = Rx<String?>(null);
  final isOriginal = true.obs;
  final capturedImagePath = Rx<String?>(null);
  bool _closed = false;

  CameraDescription? get currentCamera =>
      (cameras.isNotEmpty && currentCameraIndex.value < cameras.length)
          ? cameras[currentCameraIndex.value]
          : null;

  bool get isReady => controller.value?.value.isInitialized == true;
  int get totalCameras => cameras.length;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[CameraTest] Khởi tạo bài test tự động với ${cameras.length} camera:');
    for (int i = 0; i < cameras.length; i++) {
      final c = cameras[i];
      debugPrint('[CameraTest]  - Cam #$i: name=${c.name}, lens=${c.lensDirection}');
    }
    _verifyCameraConfiguration();
    if (cameras.isNotEmpty) {
      _openCamera(cameras[currentCameraIndex.value]);
    }
  }

  @override
  void onClose() {
    _closed = true;
    _disposeCameraSync();
    _cleanupCapturedImage();
    super.onClose();
  }

  // ==================== KHỞI TẠO & THIẾT LẬP ====================
  void _verifyCameraConfiguration() {
    final total = cameras.length;
    if (total == 0) {
      cameraWarning.value = LocaleKeys.camera_test_error_no_camera_detected.trans();
      isOriginal.value = false;
    }
  }

  // ==================== VÒNG ĐỜI CAMERA ====================
  Future<void> _openCamera(CameraDescription camera) async {
    isInitializing.value = true;
    // Xoá luôn ảnh tạm của camera trước đó — nếu chỉ gán null, file cũ sẽ
    // bị rò rỉ vì _runAutoTest() chỉ dọn file NGAY TRƯỚC lần chụp kế tiếp,
    // còn capturedImagePath đã bị null ở đây nên mất luôn đường dẫn để xoá.
    await _cleanupCapturedImage();
    isAutoCapturing.value = false;
    await _disposeCameraSync();

    final cam = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cam.initialize();

      // Đợi ổn định trước khi gắn CameraPreview vào cây widget — vài khung
      // hình đầu tiên từ Texture mới khởi tạo có thể bị chớp màu (đỏ/hồng),
      // lỗi đã biết của camera_android_camerax. Camera vẫn chạy ngầm trong
      // lúc chờ nên khi hiện preview, khung hình đã ổn định.
      await Future.delayed(CameraTestConstants.previewStabilizeDelay);
      if (_closed) {
        await cam.dispose();
        return;
      }

      controller.value = cam;
      isInitializing.value = false;
      debugPrint(
        '[CameraTest] Mở thành công Camera #${currentCameraIndex.value} (${camera.name}, ${camera.lensDirection})',
      );

      _runAutoTest();
    } catch (e) {
      isInitializing.value = false;
      debugPrint('[CameraTest] Lỗi khởi tạo Camera #${currentCameraIndex.value}: $e');
      cameraResults[currentCameraIndex.value] = false;
      Get.snackbar(
        LocaleKeys.camera_test_error_title.trans(),
        LocaleKeys.camera_test_error_init_camera.trans(namedArgs: {'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
      );
      _scheduleNextCamera();
    }
  }

  Future<void> _runAutoTest() async {
    final cam = controller.value;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      await cam.setFocusMode(FocusMode.auto);
    } catch (_) {}

    isAutoCapturing.value = true;
    await Future.delayed(CameraTestConstants.autoCaptureDelay);
    if (controller.value != cam) return; // Đã đổi camera hoặc thoát

    bool passed = false;
    try {
      await _cleanupCapturedImage();
      final image = await cam.takePicture();
      capturedImagePath.value = image.path;
      
      final isBlack = await _isImageBlack(image.path);
      if (isBlack) {
        debugPrint('[CameraTest] Lỗi: Phát hiện ảnh đen ở Camera #${currentCameraIndex.value}');
      }
      passed = !isBlack;
    } catch (e) {
      debugPrint('[CameraTest] Lỗi chụp ảnh tự động: $e');
      passed = false;
    }

    isAutoCapturing.value = false;
    cameraResults[currentCameraIndex.value] = passed;

    await Future.delayed(CameraTestConstants.postCaptureDelay);
    if (controller.value != cam) return; // Đã đổi camera hoặc thoát

    _scheduleNextCamera();
  }
  
  void _scheduleNextCamera() {
    if (currentCameraIndex.value + 1 < cameras.length) {
      currentCameraIndex.value = currentCameraIndex.value + 1;
      _openCamera(cameras[currentCameraIndex.value]);
    } else {
      bool allPassed = true;
      for (int i = 0; i < cameras.length; i++) {
        if (cameraResults[i] != true) {
          allPassed = false;
          break;
        }
      }
      finish(allPassed);
    }
  }

  Future<bool> _isImageBlack(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: CameraTestConstants.blackFrameAnalysisResizeSize,
        targetHeight: CameraTestConstants.blackFrameAnalysisResizeSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return false;

      final data = byteData.buffer.asUint8List();
      int totalLuminance = 0;
      for (int i = 0; i < data.length; i += 4) {
        final r = data[i];
        final g = data[i + 1];
        final b = data[i + 2];
        totalLuminance += ((r * 299) + (g * 587) + (b * 114)) ~/ 1000;
      }
      final meanLuminance = totalLuminance / (data.length / 4);
      return meanLuminance < CameraTestConstants.blackFrameLuminanceThreshold;
    } catch (e) {
      debugPrint('[CameraTest] Lỗi phân tích ảnh: $e');
      return true; // Coi là lỗi nếu không thể decode
    }
  }

  void finish(bool passed) {
    _disposeCameraSync();
    Get.back(result: passed);
  }

  // ==================== DỌN DẸP TÀI NGUYÊN ====================
  Future<void> _disposeCameraSync() async {
    final cam = controller.value;
    if (cam == null) return;

    // Gỡ tham chiếu khỏi UI TRƯỚC khi dispose() — nếu dispose() chạy trong
    // lúc CameraPreview vẫn còn lắng nghe controller này, listener nội bộ
    // của nó (ValueListenableBuilder trong package camera) có thể bị notify
    // ngay giữa lúc dispose() đang chạy và ném lỗi "Disposed
    // CameraController, buildPreview() was called on a disposed
    // CameraController". Đợi hết 1 frame để Flutter thực sự unmount
    // CameraPreview cũ trước khi huỷ tài nguyên native bên dưới.
    controller.value = null;
    try {
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {}

    try {
      try {
        await cam.stopImageStream();
      } catch (_) {}
      await cam.dispose();
    } catch (_) {}
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
