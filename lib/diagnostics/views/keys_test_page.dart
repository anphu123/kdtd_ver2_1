import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Màn hình kiểm tra phím vật lý (Volume Up/Down, Back, Power thủ công)
class KeysTestPage extends StatefulWidget {
  const KeysTestPage({super.key});

  @override
  State<KeysTestPage> createState() => _KeysTestPageState();
}

class _KeysTestPageState extends State<KeysTestPage> {
  final _focusNode = FocusNode();

  bool volUp = false;
  bool volDown = false;
  bool backPressed = false;
  bool powerConfirmed = false;

  bool volUpFailed = false;
  bool volDownFailed = false;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  // Native key event stream (Android Activity)
  static const _keyEventChannel = EventChannel('com.fidobox/diagnostics_keyevents');
  StreamSubscription<Map<dynamic, dynamic>>? _keySub;
  // Sub riêng cho dialog (one-shot)
  StreamSubscription<Map<dynamic, dynamic>>? _dialogKeySub;

  @override
  void initState() {
    super.initState();

    // Lấy focus để nhận key từ framework (nếu có)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });

    // Lắng nghe sự kiện phím từ native (EventChannel)
    _keySub = _keyEventChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((event) => (event as Map).cast<dynamic, dynamic>())
        .listen((m) {
      try {
        final keyCode = m['keyCode'] as int?;
        final action = m['action'] as String?;
        if (action == 'down') {
          if (keyCode == 24) {
            if (!volUp && mounted) {
              setState(() {
                volUp = true;
                volUpFailed = false;
              });
            }
          } else if (keyCode == 25) {
            if (!volDown && mounted) {
              setState(() {
                volDown = true;
                volDownFailed = false;
              });
            }
          } else if (keyCode == 4) {
            if (!backPressed && mounted) {
              setState(() => backPressed = true);
            }
          }
          if (volUp && volDown) {
            _cancelCountdown();
          }
        }
      } catch (_) {
        // ignore malformed events
      }
    }, onError: (e) {
      // ignore
    });

    // Mặc định chạy đếm ngược 5s cho bài test volume
    _startVolumeCountdown(seconds: 5);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _dialogKeySub?.cancel();
    _keySub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.physicalKey;
      if (key == PhysicalKeyboardKey.audioVolumeUp) {
        if (!volUp && mounted) setState(() => volUp = true);
        return KeyEventResult.handled;
      }
      if (key == PhysicalKeyboardKey.audioVolumeDown) {
        if (!volDown && mounted) setState(() => volDown = true);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _finishIfReady() {
    final passed = volUp && volDown;
    final result = {
      'userConfirm': passed,            // pass khi 2 phím volume OK
      'volumeUp': volUp,
      'volumeDown': volDown,
      'back': backPressed,
      'powerManualConfirm': powerConfirmed, // tick thủ công phím nguồn
    };
    Get.back(result: result);
  }

  void _startVolumeCountdown({int seconds = 5}) {
    _cancelCountdown();
    if (!mounted) return;
    setState(() {
      volUp = false;
      volDown = false;
      volUpFailed = false;
      volDownFailed = false;
      _remainingSeconds = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds -= 1;
        if (_remainingSeconds <= 0) {
          if (!volUp) volUpFailed = true;
          if (!volDown) volDownFailed = true;
          _cancelCountdown();
        }
      });
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  /// Hiện dialog yêu cầu bấm đúng `expectedKeyCode` trong `seconds`.
  /// Trả về true nếu bấm đúng hạn.
  Future<bool> _askForKeyDialog(String title, int expectedKeyCode, {int seconds = 5}) async {
    bool completed = false;
    Timer? dlgTimer;

    void cleanup() {
      dlgTimer?.cancel();
      _dialogKeySub?.cancel();
      _dialogKeySub = null;
    }

    try {
      _dialogKeySub = _keyEventChannel
          .receiveBroadcastStream()
          .map<Map<dynamic, dynamic>>((event) => (event as Map).cast<dynamic, dynamic>())
          .listen((m) {
        try {
          final keyCode = m['keyCode'] as int?;
          final action = m['action'] as String?;
          if (action == 'down' && keyCode == expectedKeyCode) {
            completed = true;
            cleanup();
            final nav = Navigator.of(context, rootNavigator: true);
            if (nav.mounted) nav.pop(true);
          }
        } catch (_) {}
      }, onError: (e) {});
    } on MissingPluginException catch (_) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Plugin chưa sẵn sàng'),
          content: const Text(
              'Native EventChannel chưa được đăng ký. Vui lòng khởi động lại ứng dụng (full restart).'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
      return false;
    } catch (_) {
      return false;
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int remaining = seconds;
        Timer? localTimer;

        return StatefulBuilder(
          builder: (c, setSt) {
            localTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!Navigator.of(c).mounted) return;
              setSt(() {
                remaining -= 1;
                if (remaining <= 0) {
                  t.cancel();
                  cleanup();
                  Navigator.of(c, rootNavigator: true).pop(false);
                }
              });
            });

            return AlertDialog(
              title: Text(title),
              content: Text('Vui lòng nhấn phím trong $remaining giây'),
              actions: [
                TextButton(
                  onPressed: () {
                    localTimer?.cancel();
                    cleanup();
                    Navigator.of(c, rootNavigator: true).pop(false);
                  },
                  child: const Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    );

    return ok == true && completed;
  }

  /// Chạy tự động: hỏi Volume Up rồi Volume Down
  Future<void> _runAutoVolumeSequence() async {
    final upOk = await _askForKeyDialog('Nhấn 1 lần phím Tăng âm lượng', 24, seconds: 5);
    if (mounted) {
      setState(() {
        if (upOk) {
          volUp = true;
          volUpFailed = false;
        } else {
          volUpFailed = true;
        }
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final downOk = await _askForKeyDialog('Nhấn 1 lần phím Giảm âm lượng', 25, seconds: 5);
    if (mounted) {
      setState(() {
        if (downOk) {
          volDown = true;
          volDownFailed = false;
        } else {
          volDownFailed = true;
        }
      });
    }

    if (volUp && volDown) {
      _cancelCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && mounted) {
          setState(() => backPressed = true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kiểm tra phím vật lý'),
        ),
        body: SafeArea(
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKeyEvent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nhấn các phím vật lý để kiểm tra.\n\n'
                        'Gợi ý: Một số thiết bị Android có thể không gửi sự kiện Volume vào app. '
                        'Bạn có thể đánh dấu thủ công phím Nguồn.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _runAutoVolumeSequence,
                        child: const Text('Chạy tự động (Volume + rồi -)'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => _startVolumeCountdown(seconds: 5),
                        child: const Text('Bắt đầu đếm ngược 5s'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_remainingSeconds > 0)
                    Card(
                      color: Colors.yellow[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Vui lòng nhấn Volume + và Volume - trong $_remainingSeconds giây'),
                      ),
                    ),

                  _KeyTile(
                    label: 'Volume +',
                    active: volUp,
                    failed: volUpFailed,
                    icon: Icons.volume_up_rounded,
                    action: () => setState(() => volUp = true),
                  ),
                  _KeyTile(
                    label: 'Volume -',
                    active: volDown,
                    failed: volDownFailed,
                    icon: Icons.volume_down_rounded,
                    action: () => setState(() => volDown = true),
                  ),
                  _KeyTile(
                    label: 'Back',
                    active: backPressed,
                    icon: Icons.arrow_back_rounded,
                    action: () => setState(() => backPressed = true),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: powerConfirmed,
                        onChanged: (v) => setState(() => powerConfirmed = v ?? false),
                      ),
                      const Expanded(
                        child: Text('Tôi đã kiểm tra phím Nguồn (không thể bắt sự kiện trực tiếp).'),
                      ),
                    ],
                  ),

                  const Spacer(),
                  FilledButton(
                    onPressed: (volUp && volDown) ? _finishIfReady : null,
                    child: const Text('Hoàn tất'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyTile extends StatelessWidget {
  final String label;
  final bool active;
  final bool failed;
  final IconData icon;
  final VoidCallback action;

  const _KeyTile({
    required this.label,
    required this.active,
    required this.icon,
    required this.action,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle =
    active ? 'Đã nhận' : (failed ? 'Không nhận (Thất bại)' : 'Chưa nhận');

    final Color? bg = active ? Colors.grey.shade200 : null;
    final Color? iconColor = active ? Theme.of(context).colorScheme.primary : null;

    return Card(
      elevation: 0,
      color: bg,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label),
        subtitle: Text(
          subtitle,
          style: failed ? const TextStyle(color: Colors.red) : null,
        ),
        trailing: TextButton(
          onPressed: action,
          child: const Text('Đánh dấu'),
        ),
      ),
    );
  }
}
