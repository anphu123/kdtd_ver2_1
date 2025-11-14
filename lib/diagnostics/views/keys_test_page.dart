import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Test phím vật lý - Chỉ hiển thị dialog với countdown
class KeysTestPage extends StatefulWidget {
  const KeysTestPage({super.key});

  @override
  State<KeysTestPage> createState() => _KeysTestPageState();
}

class _KeysTestPageState extends State<KeysTestPage> {
  static const _keyEventChannel = EventChannel(
    'com.fidobox/diagnostics_keyevents',
  );
  StreamSubscription<Map<dynamic, dynamic>>? _dialogKeySub;

  @override
  void initState() {
    super.initState();
    // Tự động bắt đầu test khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runTest();
    });
  }

  @override
  void dispose() {
    _dialogKeySub?.cancel();
    super.dispose();
  }

  /// Chạy test: Volume Up → Volume Down
  Future<void> _runTest() async {
    final upOk = await _showKeyDialog(
      'Nhấn phím Tăng âm lượng (Volume +)',
      24, // keyCode for Volume Up
      seconds: 5,
    );

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));

    final downOk = await _showKeyDialog(
      'Nhấn phím Giảm âm lượng (Volume -)',
      25, // keyCode for Volume Down
      seconds: 5,
    );

    // Trả kết quả về
    if (mounted) {
      final result = {
        'userConfirm': upOk && downOk,
        'volumeUp': upOk,
        'volumeDown': downOk,
      };
      Get.back(result: result);
    }
  }

  /// Hiển thị dialog với countdown và nhận sự kiện phím
  Future<bool> _showKeyDialog(
    String title,
    int expectedKeyCode, {
    int seconds = 5,
  }) async {
    bool keyPressed = false;

    void cleanup() {
      _dialogKeySub?.cancel();
      _dialogKeySub = null;
    }

    // Lắng nghe sự kiện phím
    try {
      _dialogKeySub = _keyEventChannel
          .receiveBroadcastStream()
          .map<Map<dynamic, dynamic>>(
            (event) => (event as Map).cast<dynamic, dynamic>(),
          )
          .listen((m) {
            try {
              final keyCode = m['keyCode'] as int?;
              final action = m['action'] as String?;
              if (action == 'down' && keyCode == expectedKeyCode) {
                keyPressed = true;
                cleanup();
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop(true);
                }
              }
            } catch (_) {}
          });
    } catch (_) {
      return false;
    }

    // Hiển thị dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int remaining = seconds;
        Timer? timer;

        return StatefulBuilder(
          builder: (c, setSt) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              setSt(() {
                remaining -= 1;
                if (remaining <= 0) {
                  t.cancel();
                  cleanup();
                  if (Navigator.of(c).canPop()) {
                    Navigator.of(c, rootNavigator: true).pop(false);
                  }
                }
              });
            });

            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$remaining',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('giây'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    cleanup();
                    Navigator.of(c, rootNavigator: true).pop(false);
                  },
                  child: const Text('Bỏ qua'),
                ),
              ],
            );
          },
        );
      },
    );

    cleanup();
    return result == true && keyPressed;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
