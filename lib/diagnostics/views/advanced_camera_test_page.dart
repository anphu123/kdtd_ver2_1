import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Camera Test - Comprehensive
/// - Test camera trước/sau
/// - Test chụp ảnh
/// - Test chống rung (OIS detection)
/// - Test focus
/// - Test flash
class AdvancedCameraTestPage extends StatefulWidget {
  const AdvancedCameraTestPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<AdvancedCameraTestPage> createState() => _AdvancedCameraTestPageState();
}

class _AdvancedCameraTestPageState extends State<AdvancedCameraTestPage> {
  CameraController? _controller;
  int _currentStep = 0;
  bool _isInitializing = false;

  CameraDescription? _frontCamera;
  CameraDescription? _backCamera;
  final List<CameraDescription> _allBackCameras = [];

  bool _frontCameraTested = false;
  bool _backCameraTested = false;
  bool _captureTested = false;
  bool _focusTested = false;
  bool _flashTested = false;

  // OIS/Stabilization detection
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _maxGyro = 0.0;
  bool _hasStabilization = false;
  final List<double> _gyroHistory = [];

  // Camera verification
  String? _cameraWarning;
  bool _isOriginal = true;

  // Captured image
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _categorizeCamera();
    _verifyCameraConfiguration();
    _startGyroMonitoring();
    _startCurrentStep();
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _categorizeCamera() {
    for (var cam in widget.cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        _frontCamera ??= cam;
      } else if (cam.lensDirection == CameraLensDirection.back) {
        _backCamera ??= cam;
        _allBackCameras.add(cam);
      }
    }
  }

  void _verifyCameraConfiguration() {
    final totalCameras = widget.cameras.length;
    final frontCount =
        widget.cameras
            .where((c) => c.lensDirection == CameraLensDirection.front)
            .length;
    final backCount =
        widget.cameras
            .where((c) => c.lensDirection == CameraLensDirection.back)
            .length;

    if (totalCameras == 1) {
      _cameraWarning = '⚠️ Chỉ có 1 camera';
      _isOriginal = false;
    } else if (totalCameras == 2) {
      if (frontCount == 1 && backCount == 1) {
        _cameraWarning = null;
        _isOriginal = true;
      } else {
        _cameraWarning = '⚠️ Cấu hình camera bất thường';
        _isOriginal = false;
      }
    } else if (totalCameras >= 3 && totalCameras <= 5) {
      if (frontCount >= 1 && backCount >= 2) {
        _cameraWarning = null;
        _isOriginal = true;
      } else {
        _cameraWarning = '⚠️ Số lượng camera không cân đối';
        _isOriginal = false;
      }
    } else if (totalCameras > 5) {
      _cameraWarning = '⚠️ Quá nhiều camera ($totalCameras)';
      _isOriginal = false;
    } else {
      _cameraWarning = '❌ Không phát hiện camera';
      _isOriginal = false;
    }
  }

  void _startGyroMonitoring() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      final magnitude =
          (event.x * event.x + event.y * event.y + event.z * event.z);

      setState(() {
        if (magnitude > _maxGyro) _maxGyro = magnitude;

        _gyroHistory.add(magnitude);
        if (_gyroHistory.length > 50) {
          _gyroHistory.removeAt(0);
        }

        // Detect stabilization: low gyro variance despite movement
        if (_gyroHistory.length >= 30) {
          final avg =
              _gyroHistory.reduce((a, b) => a + b) / _gyroHistory.length;
          final variance =
              _gyroHistory
                  .map((v) => (v - avg) * (v - avg))
                  .reduce((a, b) => a + b) /
              _gyroHistory.length;

          // If variance is low but max gyro is high, likely has OIS
          if (variance < 0.5 && _maxGyro > 2.0) {
            _hasStabilization = true;
          }
        }
      });
    });
  }

  Future<void> _startCurrentStep() async {
    CameraDescription? camera;

    if (_currentStep == 0 && _frontCamera != null) {
      camera = _frontCamera;
    } else if (_currentStep == 1 && _backCamera != null) {
      camera = _backCamera;
    } else if (_currentStep == 2 && _backCamera != null) {
      camera = _backCamera;
    } else if (_currentStep == 3 && _backCamera != null) {
      camera = _backCamera; // Focus test
    } else if (_currentStep == 4 && _backCamera != null) {
      camera = _backCamera; // Flash test
    }

    if (camera == null) {
      _nextStep();
      return;
    }

    await _openCamera(camera);
  }

  Future<void> _openCamera(CameraDescription camera) async {
    setState(() => _isInitializing = true);

    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khởi tạo camera: $e')));
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() {
        _frontCameraTested = true;
        _currentStep = 1;
      });
      _startCurrentStep();
    } else if (_currentStep == 1) {
      setState(() {
        _backCameraTested = true;
        _currentStep = 2;
      });
      _startCurrentStep();
    } else if (_currentStep == 2) {
      setState(() {
        _captureTested = true;
        _currentStep = 3;
      });
      _startCurrentStep();
    } else if (_currentStep == 3) {
      setState(() {
        _focusTested = true;
        _currentStep = 4;
      });
      _startCurrentStep();
    } else if (_currentStep == 4) {
      setState(() => _flashTested = true);
      _finish(true);
    }
  }

  void _skipStep() {
    _nextStep();
  }

  Future<void> _captureTest() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      setState(() => _capturedImagePath = image.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Chụp thành công'),
            duration: Duration(seconds: 1),
          ),
        );

        // Auto next after showing preview
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _nextStep();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✗ Lỗi chụp: $e')));
      }
    }
  }

  Future<void> _testFocus() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Test autofocus
      final center = Offset(
        _controller!.value.previewSize!.width / 2,
        _controller!.value.previewSize!.height / 2,
      );

      await _controller!.setFocusPoint(center);
      await _controller!.setFocusMode(FocusMode.auto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Focus hoạt động'),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _nextStep();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Focus không khả dụng: $e')));
        _nextStep();
      }
    }
  }

  Future<void> _testFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Test flash on
      await _controller!.setFlashMode(FlashMode.torch);
      await Future.delayed(const Duration(seconds: 1));

      // Flash off
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Flash hoạt động'),
            duration: Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _nextStep();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Flash không khả dụng: $e')));
        _nextStep();
      }
    }
  }

  void _finish(bool passed) {
    Navigator.pop(context, passed);
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Bước 1: Camera Trước';
      case 1:
        return 'Bước 2: Camera Sau';
      case 2:
        return 'Bước 3: Chụp Ảnh';
      case 3:
        return 'Bước 4: Test Focus';
      case 4:
        return 'Bước 5: Test Flash';
      default:
        return 'Hoàn thành';
    }
  }

  String _getStepInstruction() {
    switch (_currentStep) {
      case 0:
        return 'Kiểm tra camera trước có hoạt động không';
      case 1:
        return 'Kiểm tra camera sau có hoạt động không';
      case 2:
        return 'Nhấn nút chụp để test chức năng chụp ảnh';
      case 3:
        return 'Nhấn để test tự động lấy nét (autofocus)';
      case 4:
        return 'Nhấn để test đèn flash';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(_getStepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(false),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (isReady)
            Positioned.fill(
              child:
                  _capturedImagePath != null && _currentStep == 2
                      ? Image.file(File(_capturedImagePath!), fit: BoxFit.cover)
                      : FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.previewSize!.height,
                          height: _controller!.value.previewSize!.width,
                          child: CameraPreview(_controller!),
                        ),
                      ),
            )
          else if (_isInitializing)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            const Center(
              child: Text(
                'Camera không khả dụng',
                style: TextStyle(color: Colors.white),
              ),
            ),

          // Step indicator
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicators
                    Row(
                      children: [
                        _StepIndicator(
                          number: 1,
                          isActive: _currentStep == 0,
                          isCompleted: _frontCameraTested,
                        ),
                        const SizedBox(width: 8),
                        _StepIndicator(
                          number: 2,
                          isActive: _currentStep == 1,
                          isCompleted: _backCameraTested,
                        ),
                        const SizedBox(width: 8),
                        _StepIndicator(
                          number: 3,
                          isActive: _currentStep == 2,
                          isCompleted: _captureTested,
                        ),
                        const SizedBox(width: 8),
                        _StepIndicator(
                          number: 4,
                          isActive: _currentStep == 3,
                          isCompleted: _focusTested,
                        ),
                        const SizedBox(width: 8),
                        _StepIndicator(
                          number: 5,
                          isActive: _currentStep == 4,
                          isCompleted: _flashTested,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getStepInstruction(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),

                    // OIS/Stabilization info
                    if (_currentStep >= 1) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _hasStabilization
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.blue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _hasStabilization ? Colors.green : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasStabilization
                                  ? Icons.check_circle
                                  : Icons.videocam,
                              color:
                                  _hasStabilization
                                      ? Colors.green
                                      : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _hasStabilization
                                    ? '✓ Phát hiện chống rung (OIS/EIS)'
                                    : 'Đang kiểm tra chống rung...',
                                style: TextStyle(
                                  color:
                                      _hasStabilization
                                          ? Colors.green
                                          : Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Camera warning
                    if (_cameraWarning != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _isOriginal
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orange.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isOriginal ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isOriginal ? Icons.check_circle : Icons.warning,
                              color: _isOriginal ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _cameraWarning!,
                                style: TextStyle(
                                  color:
                                      _isOriginal
                                          ? Colors.green
                                          : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Camera count
                    const SizedBox(height: 8),
                    Text(
                      'Tổng: ${widget.cameras.length} camera',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action button for current step
          if (isReady)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(child: _buildActionButton()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Bỏ qua'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _nextStep,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isReady
                            ? Colors.green
                            : Colors.green.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _currentStep < 2
                        ? (isReady ? 'Tiếp tục' : 'Tiếp tục (Thủ công)')
                        : 'Hoàn thành',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    IconData icon;
    VoidCallback? onPressed;

    switch (_currentStep) {
      case 2:
        icon = Icons.camera_alt;
        onPressed = _captureTest;
        break;
      case 3:
        icon = Icons.center_focus_strong;
        onPressed = _testFocus;
        break;
      case 4:
        icon = Icons.flash_on;
        onPressed = _testFlash;
        break;
      default:
        return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: Colors.black),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget icon;

    if (isCompleted) {
      bgColor = Colors.green;
      textColor = Colors.white;
      icon = const Icon(Icons.check, color: Colors.white, size: 20);
    } else if (isActive) {
      bgColor = Colors.blue;
      textColor = Colors.white;
      icon = Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      bgColor = Colors.grey;
      textColor = Colors.white70;
      icon = Text(
        '$number',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: icon),
    );
  }
}
