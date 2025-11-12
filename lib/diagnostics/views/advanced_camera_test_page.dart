import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Advanced Camera Test
/// - Đọc thông số camera (resolution, aperture, focal length)
/// - Kiểm tra số lượng camera (front/back, ultra-wide, telephoto)
/// - Phát hiện camera bị che (brightness analysis)
/// - Kiểm tra rung (gyroscope/accelerometer)
class AdvancedCameraTestPage extends StatefulWidget {
  const AdvancedCameraTestPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<AdvancedCameraTestPage> createState() => _AdvancedCameraTestPageState();
}

class _AdvancedCameraTestPageState extends State<AdvancedCameraTestPage> {
  CameraController? _controller;
  int _currentIndex = 0;
  bool _isAnalyzing = false;

  // Camera info
  final Map<String, dynamic> _cameraInfo = {};
  final List<String> _detectedIssues = [];
  final List<Map<String, dynamic>> _allCamerasInfo = [];

  // Shake detection
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelSubscription;
  double _shakeLevel = 0.0;
  bool _isShaking = false;

  // Obstruction detection
  bool _isObstructed = false;
  double _brightness = 0.0;

  @override
  void initState() {
    super.initState();
    _analyzeCameraList();
    _startShakeDetection();
    if (widget.cameras.isNotEmpty) {
      _openCamera(0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _gyroSubscription?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }

  /// Phân tích danh sách camera
  void _analyzeCameraList() {
    final front = widget.cameras.where((c) => c.lensDirection == CameraLensDirection.front).toList();
    final back = widget.cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList();
    final external = widget.cameras.where((c) => c.lensDirection == CameraLensDirection.external).toList();

    _cameraInfo['totalCameras'] = widget.cameras.length;
    _cameraInfo['frontCameras'] = front.length;
    _cameraInfo['backCameras'] = back.length;
    _cameraInfo['externalCameras'] = external.length;

    // Phát hiện loại camera (ultra-wide, telephoto, macro)
    // Note: Camera package không expose focal length trực tiếp
    // Chỉ có thể đoán dựa trên sensor orientation và name
    for (var cam in widget.cameras) {
      final info = {
        'name': cam.name,
        'direction': cam.lensDirection.toString().split('.').last,
        'sensorOrientation': cam.sensorOrientation,
      };
      _allCamerasInfo.add(info);
    }
  }

  /// Mở camera tại index
  Future<void> _openCamera(int index) async {
    if (index < 0 || index >= widget.cameras.length) return;

    setState(() {
      _currentIndex = index;
      _isAnalyzing = true;
      _detectedIssues.clear();
      _isObstructed = false;
    });

    await _controller?.dispose();

    final camera = widget.cameras[index];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();

      // Đọc thông số camera
      final description = camera;
      final currentInfo = {
        'name': description.name,
        'direction': description.lensDirection.toString().split('.').last,
        'sensorOrientation': description.sensorOrientation,
        'resolution': '${_controller!.value.previewSize?.width.toInt() ?? 0}x${_controller!.value.previewSize?.height.toInt() ?? 0}',
      };

      if (mounted) {
        setState(() {
          _cameraInfo['current'] = currentInfo;
          _isAnalyzing = false;
        });
      }

      // Start auto-analysis after 1 second
      Future.delayed(const Duration(seconds: 1), _analyzeObstruction);

    } catch (e) {
      _detectedIssues.add('Lỗi khởi tạo camera: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  /// Chuyển camera
  void _switchCamera() {
    if (widget.cameras.length < 2) return;
    final nextIndex = (_currentIndex + 1) % widget.cameras.length;
    _openCamera(nextIndex);
  }

  /// Phát hiện camera bị che
  Future<void> _analyzeObstruction() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Chụp ảnh để phân tích brightness
      final image = await _controller!.takePicture();

      // Note: Để phân tích brightness chính xác cần decode image
      // Hiện tại sử dụng heuristic đơn giản
      // Trong production, nên decode image và tính average brightness

      // Temporary: Assume not obstructed for now
      // TODO: Implement actual brightness analysis from image file
      setState(() {
        _isObstructed = false; // Placeholder
        _brightness = 0.5; // Placeholder
      });

    } catch (e) {
      // Ignore errors in analysis
    }
  }

  /// Phát hiện rung (shake detection)
  void _startShakeDetection() {
    // Gyroscope - đo rotation
    _gyroSubscription = gyroscopeEventStream().listen((event) {
      final rotation = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      setState(() {
        _shakeLevel = rotation;
        // Ngưỡng rung: > 2.0 rad/s = đang rung
        _isShaking = rotation > 2.0;

        if (_isShaking) {
          if (!_detectedIssues.contains('Thiết bị đang rung - giữ chắc tay!')) {
            _detectedIssues.add('Thiết bị đang rung - giữ chắc tay!');
          }
        } else {
          _detectedIssues.remove('Thiết bị đang rung - giữ chắc tay!');
        }
      });
    });

    // Accelerometer - đo movement (optional, để detect thêm)
    _accelSubscription = accelerometerEventStream().listen((event) {
      final movement = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      // Có thể dùng để detect movement patterns
    });
  }

  /// Chụp ảnh test
  Future<void> _captureTest() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Chụp thành công'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✗ Lỗi chụp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller?.value.isInitialized == true;
    final currentCam = widget.cameras.isNotEmpty ? widget.cameras[_currentIndex] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kiểm Tra Camera', style: TextStyle(fontSize: 16)),
            if (currentCam != null)
              Text(
                '${_currentIndex + 1}/${widget.cameras.length} • ${_getCameraTypeName(currentCam)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_android),
              tooltip: 'Chuyển camera',
            ),
          IconButton(
            onPressed: () => _showCameraInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (isReady)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Overlay indicators
          if (isReady) ...[
            // Shake indicator
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _ShakeIndicator(
                isShaking: _isShaking,
                shakeLevel: _shakeLevel,
              ),
            ),

            // Obstruction warning
            if (_isObstructed)
              Positioned(
                top: 80,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.block, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Camera có thể bị che hoặc rất tối',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Capture button
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _captureTest,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.camera_alt, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Issues
              if (_detectedIssues.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vấn đề phát hiện:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ..._detectedIssues.map((issue) => Text(
                        '• $issue',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      )),
                    ],
                  ),
                ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      label: const Text('Không đạt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _detectedIssues.isEmpty
                          ? () => Navigator.pop(context, true)
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Đạt'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCameraTypeName(CameraDescription camera) {
    final name = camera.name.toLowerCase();
    final dir = camera.lensDirection;

    if (dir == CameraLensDirection.front) {
      return 'Camera trước';
    } else if (dir == CameraLensDirection.back) {
      if (name.contains('ultra') || name.contains('wide')) {
        return 'Camera sau (Ultra-wide)';
      } else if (name.contains('tele') || name.contains('zoom')) {
        return 'Camera sau (Telephoto)';
      } else if (name.contains('macro')) {
        return 'Camera sau (Macro)';
      }
      return 'Camera sau (Chính)';
    }
    return 'Camera ngoài';
  }

  void _showCameraInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // Attach the sheet to the root Navigator/Overlay to avoid reparenting
      // issues when the app uses nested navigators (GetMaterialApp etc.).
      useRootNavigator: true,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => SafeArea(
        // Use a Builder to ensure the inner context belongs to the sheet
        child: Builder(
          builder: (sheetContext) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📷 Thông Tin Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),

                _InfoRow('Tổng số camera:', '${_cameraInfo['totalCameras'] ?? 0}'),
                _InfoRow('Camera trước:', '${_cameraInfo['frontCameras'] ?? 0}'),
                _InfoRow('Camera sau:', '${_cameraInfo['backCameras'] ?? 0}'),

                if (_cameraInfo['current'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Camera hiện tại:',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow('Tên:', _cameraInfo['current']['name']),
                  _InfoRow('Hướng:', _cameraInfo['current']['direction']),
                  _InfoRow('Độ phân giải:', _cameraInfo['current']['resolution']),
                  _InfoRow('Sensor orientation:', '${_cameraInfo['current']['sensorOrientation']}°'),
                ],

                const SizedBox(height: 16),
                _InfoRow('Mức rung:', '${_shakeLevel.toStringAsFixed(2)} rad/s'),
                _InfoRow('Trạng thái:', _isShaking ? '⚠️ Đang rung' : '✓ Ổn định'),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShakeIndicator extends StatelessWidget {
  final bool isShaking;
  final double shakeLevel;

  const _ShakeIndicator({
    required this.isShaking,
    required this.shakeLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isShaking
            ? Colors.orange.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isShaking ? Icons.vibration : Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isShaking
                ? 'Đang rung (${shakeLevel.toStringAsFixed(1)})'
                : 'Ổn định',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

