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

  /// Lỗi khởi tạo/chụp của camera hiện tại, hiện ngay trong màn thay vì
  /// snackbar (snackbar trong dialog làm kẹt mọi `Get.back()` sau đó).
  final cameraError = Rx<String?>(null);
  final isOriginal = true.obs;

  /// Số giây còn lại trước khi tự chụp; 0 nghĩa là không đang đếm.
  final captureCountdown = 0.obs;
  final capturedImagePath = Rx<String?>(null);
  bool _closed = false;
  bool _finished = false;

  CameraDescription? get currentCamera =>
      (cameras.isNotEmpty && currentCameraIndex.value < cameras.length)
          ? cameras[currentCameraIndex.value]
          : null;

  bool get isReady => controller.value?.value.isInitialized == true;
  int get totalCameras => cameras.length;

  @override
  void onInit() {
    super.onInit();
    debugPrint(
      '[CameraTest] Khởi tạo bài test tự động với ${cameras.length} camera:',
    );
    for (int i = 0; i < cameras.length; i++) {
      final c = cameras[i];
      debugPrint(
        '[CameraTest]  - Cam #$i: name=${c.name}, lens=${c.lensDirection}',
      );
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
      cameraWarning.value =
          LocaleKeys.camera_test_error_no_camera_detected.trans();
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
    captureCountdown.value = 0;
    cameraError.value = null;
    await _disposeCameraSync();
    if (_closed) return;

    final cam = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cam.initialize();
      if (_closed) {
        await cam.dispose();
        return;
      }

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
      cameraError.value = null;
      debugPrint(
        '[CameraTest] Mở thành công Camera #${currentCameraIndex.value} '
        '(${camera.name}, ${camera.lensDirection}) '
        'previewSize=${cam.value.previewSize}',
      );

      _runAutoTest();
    } catch (e) {
      isInitializing.value = false;
      debugPrint(
        '[CameraTest] Lỗi khởi tạo Camera #${currentCameraIndex.value}: $e',
      );
      cameraResults[currentCameraIndex.value] = false;
      cameraError.value = LocaleKeys.camera_test_error_init_camera.trans(
        namedArgs: {'error': '$e'},
      );
      // Giữ lỗi hiện trên màn một lúc để kỹ thuật viên kịp đọc.
      await Future.delayed(CameraTestConstants.postCaptureDelay);
      if (_closed) return;
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

    // Đếm ngược từng giây thay vì chờ lặng: người dùng thấy được còn bao lâu
    // để hướng máy đúng chỗ. Kiểm tra `controller.value != cam` sau MỖI giây
    // để thoát ngay khi đổi camera hoặc đóng màn, không chụp nhầm.
    for (var i = CameraTestConstants.autoCaptureCountdownSeconds; i > 0; i--) {
      captureCountdown.value = i;
      await Future.delayed(const Duration(seconds: 1));
      if (controller.value != cam) {
        captureCountdown.value = 0;
        return;
      }
    }
    captureCountdown.value = 0;

    bool passed = false;
    try {
      await _cleanupCapturedImage();
      final image = await cam.takePicture();
      capturedImagePath.value = image.path;

      final luminance = await _meanLuminance(image.path);
      final fileSize = await File(image.path).length();
      final isBlack =
          luminance == null ||
          luminance < CameraTestConstants.blackFrameLuminanceThreshold;

      debugPrint(
        '[CameraTest] Cam #${currentCameraIndex.value} chụp xong: '
        'độ sáng=${luminance?.toStringAsFixed(1) ?? "không decode được"}/255 '
        '(ngưỡng ${CameraTestConstants.blackFrameLuminanceThreshold}), '
        'file=${(fileSize / 1024).toStringAsFixed(0)}KB, '
        'kết luận=${isBlack ? "ĐEN -> FAIL" : "OK"}',
      );
      passed = !isBlack;
    } catch (e) {
      debugPrint('[CameraTest] Lỗi chụp ảnh tự động: $e');
      passed = false;
    }

    isAutoCapturing.value = false;
    captureCountdown.value = 0;
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

  /// Độ sáng trung bình (0-255) của ảnh, `null` nếu không decode được.
  ///
  /// Trả về SỐ ĐO thay vì bool: log có con số mới phân biệt được ảnh đen
  /// tuyệt đối (camera không mở được, ~0) với ảnh tối (phòng thiếu sáng,
  /// 10-20) — hai nguyên nhân khác hẳn nhau nhưng cùng rơi dưới ngưỡng.
  Future<double?> _meanLuminance(String imagePath) async {
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
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return null;

      final data = byteData.buffer.asUint8List();
      int totalLuminance = 0;
      for (int i = 0; i < data.length; i += 4) {
        final r = data[i];
        final g = data[i + 1];
        final b = data[i + 2];
        totalLuminance += ((r * 299) + (g * 587) + (b * 114)) ~/ 1000;
      }
      return totalLuminance / (data.length / 4);
    } catch (e) {
      debugPrint('[CameraTest] Lỗi phân tích ảnh: $e');
      return null;
    }
  }

  void finish(bool passed) {
    // Timer tự động và nút đóng có thể cùng kích hoạt.
    if (_finished) return;
    _finished = true;
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
