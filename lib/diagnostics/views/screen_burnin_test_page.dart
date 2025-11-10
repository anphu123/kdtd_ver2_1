import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen Burn-In & Dead Pixel Test
/// Hiển thị các màu đơn sắc để phát hiện sọc ám, vết cháy, pixel chết
class ScreenBurnInTestPage extends StatefulWidget {
  const ScreenBurnInTestPage({super.key});

  @override
  State<ScreenBurnInTestPage> createState() => _ScreenBurnInTestPageState();
}

class _ScreenBurnInTestPageState extends State<ScreenBurnInTestPage> {
  int _currentIndex = 0;
  Timer? _autoTimer;
  bool _autoMode = false;

  // Danh sách màu test (đơn sắc để dễ phát hiện vấn đề)
  final List<ScreenTestColor> _testColors = [
    ScreenTestColor('Đen (Black)', Colors.black, '🔍 Kiểm tra pixel sáng bất thường'),
    ScreenTestColor('Trắng (White)', Colors.white, '🔍 Kiểm tra pixel tối, vết ám'),
    ScreenTestColor('Đỏ (Red)', Colors.red, '🔍 Kiểm tra kênh màu đỏ'),
    ScreenTestColor('Xanh lá (Green)', Colors.green, '🔍 Kiểm tra kênh màu xanh lá'),
    ScreenTestColor('Xanh dương (Blue)', Colors.blue, '🔍 Kiểm tra kênh màu xanh dương'),
    ScreenTestColor('Xám (Gray)', Colors.grey, '🔍 Kiểm tra độ đồng đều'),
    ScreenTestColor('Vàng (Yellow)', Colors.yellow, '🔍 Kiểm tra màu ấm'),
    ScreenTestColor('Cyan', Colors.cyan, '🔍 Kiểm tra màu lạnh'),
    ScreenTestColor('Magenta', Colors.pink, '🔍 Kiểm tra màu hồng'),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _stopAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _nextColor() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _testColors.length;
    });
  }

  void _previousColor() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _testColors.length) % _testColors.length;
    });
  }

  void _toggleAutoMode() {
    if (_autoMode) {
      _stopAutoMode();
    } else {
      _startAutoMode();
    }
  }

  void _startAutoMode() {
    setState(() => _autoMode = true);
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _nextColor();
    });
  }

  void _stopAutoMode() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (mounted) setState(() => _autoMode = false);
  }

  void _finish(bool hasIssue) {
    Navigator.of(context).pop(!hasIssue); // true = no issue (pass)
  }

  @override
  Widget build(BuildContext context) {
    final current = _testColors[_currentIndex];
    final isDark = current.color.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonColor = isDark ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: current.color,
      body: SafeArea(
        child: Stack(
          children: [
            // Toàn màn hình một màu
            Container(color: current.color),

            // Controls ở trên
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tiêu đề & hướng dẫn
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.name,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current.description,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_currentIndex + 1}/${_testColors.length}',
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _previousColor,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Trước'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleAutoMode,
                          icon: Icon(_autoMode ? Icons.pause : Icons.play_arrow),
                          label: Text(_autoMode ? 'Tạm dừng' : 'Tự động'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _autoMode ? Colors.orange : buttonColor,
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _nextColor,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Sau'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hướng dẫn giữa màn hình (nhỏ, mờ)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Quan sát kỹ màn hình\nTìm sọc, vết ám, pixel bất thường',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Buttons kết quả ở dưới
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚠️ Nếu phát hiện sọc dọc/ngang, vết ám, pixel chết → nhấn "Có vấn đề"\n'
                      '✅ Nếu màn hình đồng đều, không vấn đề → nhấn "Không có vấn đề"',
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _finish(true),
                          icon: const Icon(Icons.warning_amber),
                          label: const Text('Có vấn đề'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _finish(false),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Không có vấn đề'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Back button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      foregroundColor: textColor.withOpacity(0.7),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenTestColor {
  final String name;
  final Color color;
  final String description;

  const ScreenTestColor(this.name, this.color, this.description);
}

