import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Auto Screen Burn-In Test - For Tier 5 (old/low-end devices)
/// Tự động chạy qua các màu để phát hiện sọc ám
class AutoScreenBurnInTestPage extends StatefulWidget {
  const AutoScreenBurnInTestPage({super.key});

  @override
  State<AutoScreenBurnInTestPage> createState() => _AutoScreenBurnInTestPageState();
}

class _AutoScreenBurnInTestPageState extends State<AutoScreenBurnInTestPage> {
  int _currentIndex = 0;
  Timer? _autoTimer;
  bool _isRunning = true;
  int _countdown = 3; // Đếm ngược trước khi bắt đầu
  bool _started = false;

  // Danh sách màu test (rút gọn cho auto mode)
  final List<ScreenTestColor> _testColors = [
    ScreenTestColor('Đen', Colors.black, 'Pixel sáng bất thường'),
    ScreenTestColor('Trắng', Colors.white, 'Vết ám, burn-in'),
    ScreenTestColor('Đỏ', Colors.red, 'Kênh màu đỏ'),
    ScreenTestColor('Xanh lá', Colors.green, 'Kênh màu xanh lá'),
    ScreenTestColor('Xanh dương', Colors.blue, 'Kênh màu xanh dương'),
    ScreenTestColor('Xám', Colors.grey, 'Độ đồng đều màn hình'),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startCountdown();
  }

  @override
  void dispose() {
    _stopAutoTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _started = true);
        _startAutoTest();
      }
    });
  }

  void _startAutoTest() {
    _autoTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentIndex < _testColors.length - 1) {
        setState(() => _currentIndex++);
      } else {
        // Hoàn thành - tự động PASS (nếu user không báo vấn đề)
        timer.cancel();
        _finish(false); // false = không có vấn đề
      }
    });
  }

  void _stopAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (mounted) setState(() => _isRunning = false);
  }

  void _pause() {
    _stopAutoTimer();
  }

  void _resume() {
    if (_started) {
      setState(() => _isRunning = true);
      _startAutoTest();
    }
  }

  void _finish(bool hasIssue) {
    _stopAutoTimer();
    Navigator.of(context).pop(!hasIssue); // true = no issue (pass)
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      // Màn hình countdown
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.screen_search_desktop,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              const Text(
                'Kiểm Tra Màn Hình Tự Động',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quan sát kỹ màn hình\nTìm sọc, vết ám, pixel bất thường',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '$_countdown',
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bắt đầu sau...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

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

            // Info nhỏ ở góc trên
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentIndex + 1}/${_testColors.length} • ${current.name}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            current.description,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isRunning ? _pause : _resume,
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress bar
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _testColors.length,
                  minHeight: 8,
                  backgroundColor: buttonColor,
                  valueColor: AlwaysStoppedAnimation(
                    isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  ),
                ),
              ),
            ),

            // Hướng dẫn nhỏ ở giữa
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tự động chuyển màu...\nChú ý quan sát',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Emergency buttons ở dưới
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚠️ Nếu thấy sọc/ám/pixel chết → nhấn "Có vấn đề"',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _finish(false),
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Bỏ qua'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: textColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
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

