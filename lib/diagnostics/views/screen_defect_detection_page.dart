import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tự động phát hiện lỗi màn hình: sốc, chảy mực, burn-in, dead pixel
class ScreenDefectDetectionPage extends StatefulWidget {
  const ScreenDefectDetectionPage({super.key});

  @override
  State<ScreenDefectDetectionPage> createState() =>
      _ScreenDefectDetectionPageState();
}

class _ScreenDefectDetectionPageState extends State<ScreenDefectDetectionPage> {
  int _currentStep = 0;
  Timer? _autoTimer;
  final List<ScreenDefect> _detectedDefects = [];
  bool _userConfirmedDefect = false;

  final List<TestPattern> _patterns = [
    TestPattern(
      name: 'Màu đỏ',
      color: Colors.red,
      description: 'Kiểm tra pixel đỏ, vết sốc',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xanh lá',
      color: Colors.green,
      description: 'Kiểm tra pixel xanh lá',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xanh dương',
      color: Colors.blue,
      description: 'Kiểm tra pixel xanh dương',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu trắng',
      color: Colors.white,
      description: 'Kiểm tra dead pixel, vết đen',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu đen',
      color: Colors.black,
      description: 'Kiểm tra bright pixel, chảy mực',
      duration: 3,
    ),
    TestPattern(
      name: 'Màu xám',
      color: Colors.grey,
      description: 'Kiểm tra burn-in, vết ám',
      duration: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startAutoTest();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startAutoTest() {
    _autoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final pattern = _patterns[_currentStep];
      if (timer.tick >= pattern.duration) {
        // Tự động phân tích màn hình trước khi chuyển
        _autoAnalyzeScreen();

        _nextStep();
        timer.cancel();
        if (_currentStep < _patterns.length) {
          _startAutoTest();
        }
      }
    });
  }

  /// Tự động phân tích màn hình (giả lập - trong thực tế cần camera/sensor)
  void _autoAnalyzeScreen() {
    // TODO: Implement real screen analysis using:
    // - Camera to capture screen
    // - Image processing to detect defects
    // - ML model to classify defects

    // Hiện tại: Giả lập phát hiện ngẫu nhiên (demo purpose)
    // Trong production, bỏ phần này và dùng camera thật

    // Uncomment để test auto-detection:
    // if (math.Random().nextDouble() < 0.1) { // 10% chance
    //   _reportDefect();
    // }
  }

  void _nextStep() {
    if (_currentStep < _patterns.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _reportDefect() {
    final pattern = _patterns[_currentStep];
    setState(() {
      _userConfirmedDefect = true;
      _detectedDefects.add(
        ScreenDefect(
          type: _getDefectType(pattern.name),
          color: pattern.name,
          description: 'Phát hiện lỗi khi test ${pattern.name.toLowerCase()}',
        ),
      );
    });
  }

  String _getDefectType(String colorName) {
    if (colorName.contains('đen')) return 'Chảy mực / Bright pixel';
    if (colorName.contains('trắng')) return 'Dead pixel / Vết đen';
    if (colorName.contains('xám')) return 'Burn-in / Vết ám';
    return 'Pixel lỗi / Vết sốc';
  }

  void _finish() {
    final hasDefects = _detectedDefects.isNotEmpty;
    Navigator.pop(context, {
      'passed': !hasDefects,
      'hasIssue': hasDefects, // Thêm field này cho rule evaluator
      'defects': _detectedDefects.map((d) => d.toMap()).toList(),
      'defectCount': _detectedDefects.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    final pattern = _patterns[_currentStep];
    final progress = (_currentStep + 1) / _patterns.length;

    return Scaffold(
      backgroundColor: pattern.color,
      body: Stack(
        children: [
          // Full screen color
          Positioned.fill(child: Container(color: pattern.color)),

          // Top info bar (semi-transparent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_currentStep + 1}/${_patterns.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Pattern name
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Quan sát kỹ màn hình. Nếu thấy vết lạ, nhấn "Báo lỗi"',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Report defect button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _reportDefect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.report_problem),
                        label: const Text(
                          'Báo lỗi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Skip button
                    ElevatedButton(
                      onPressed: () {
                        _autoTimer?.cancel();
                        _nextStep();
                        if (_currentStep < _patterns.length) {
                          _startAutoTest();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Defect indicator
          if (_userConfirmedDefect)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Đã ghi nhận lỗi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TestPattern {
  final String name;
  final Color color;
  final String description;
  final int duration; // seconds

  TestPattern({
    required this.name,
    required this.color,
    required this.description,
    required this.duration,
  });
}

class ScreenDefect {
  final String type;
  final String color;
  final String description;

  ScreenDefect({
    required this.type,
    required this.color,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'color': color,
    'description': description,
  };
}
