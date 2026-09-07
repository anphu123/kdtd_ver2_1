import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

import 'keys_test_controller.dart';
import 'widgets/key_tile.dart';

/// Màn hình kiểm tra phím vật lý (Volume Up/Down, Back, Power thủ công).
///
/// UI thuần — toàn bộ nghiệp vụ sống trong [KeysTestController] (gắn qua
/// `KeysTestBinding`). Trang này chỉ giữ những gì thực sự cần
/// `BuildContext`/`FocusNode`/`Navigator`/`showDialog`: fallback bàn phím
/// vật lý qua `Focus.onKeyEvent`, nút back cứng qua `PopScope`, và luồng
/// "Chạy tự động" hiển thị dialog đếm ngược trong lúc chờ
/// `controller.waitForKey(...)`.
class KeysTestPage extends GetView<KeysTestController> {
  const KeysTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _KeysTestBody(controller: controller);
  }
}

class _KeysTestBody extends StatefulWidget {
  const _KeysTestBody({required this.controller});

  final KeysTestController controller;

  @override
  State<_KeysTestBody> createState() => _KeysTestBodyState();
}

class _KeysTestBodyState extends State<_KeysTestBody> {
  final _focusNode = FocusNode();

  KeysTestController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    // Lấy focus để nhận key từ framework (nếu có)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.physicalKey;
      if (key == PhysicalKeyboardKey.audioVolumeUp) {
        controller.markVolUp();
        return KeyEventResult.handled;
      }
      if (key == PhysicalKeyboardKey.audioVolumeDown) {
        controller.markVolDown();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showMissingPluginDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plugin chưa sẵn sàng'),
        content: const Text(
            'Native EventChannel chưa được đăng ký. Vui lòng khởi động lại ứng dụng (full restart).'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Hiện dialog yêu cầu bấm đúng `expectedKeyCode` trong `seconds`, với
  /// đếm ngược hiển thị trực tiếp trong dialog. `controller.waitForKey`
  /// đảm nhiệm việc chờ key thực tế; dialog chỉ tự đóng khi future đó
  /// hoàn tất (bấm đúng phím hoặc hết giờ) hoặc khi người dùng bấm Hủy.
  Future<bool> _askForKeyDialog(String title, int expectedKeyCode, {int seconds = 5}) async {
    Future<bool> waitFuture;
    try {
      waitFuture = controller.waitForKey(expectedKeyCode, seconds: seconds);
    } on MissingPluginException {
      await _showMissingPluginDialog();
      return false;
    }

    if (!mounted) return false;

    var popped = false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int remaining = seconds;
        Timer? localTimer;

        // Đóng dialog ngay khi waitFuture hoàn tất (bấm đúng phím hoặc
        // hết giờ) thay vì chờ đếm ngược hiển thị chạy hết. Lấy
        // NavigatorState ngay lúc build (context còn hợp lệ) để dùng lại
        // an toàn bên trong callback bất đồng bộ của `.then`.
        final rootNav = Navigator.of(ctx, rootNavigator: true);
        waitFuture.then((result) {
          if (popped) return;
          popped = true;
          localTimer?.cancel();
          try {
            if (rootNav.mounted) rootNav.pop(result);
          } catch (_) {
            // Context may be disposed
          }
        });

        return StatefulBuilder(
          builder: (c, setSt) {
            localTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (popped) {
                t.cancel();
                return;
              }
              setSt(() {
                remaining -= 1;
                if (remaining <= 0) t.cancel();
              });
            });

            return AlertDialog(
              title: Text(title),
              content: Text('Vui lòng nhấn phím trong $remaining giây'),
              actions: [
                TextButton(
                  onPressed: () {
                    if (popped) return;
                    popped = true;
                    localTimer?.cancel();
                    try {
                      Navigator.of(c, rootNavigator: true).pop(false);
                    } catch (_) {
                      // Context may be disposed
                    }
                  },
                  child: const Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    );

    return ok == true;
  }

  /// Chạy tự động: hỏi Volume Up rồi Volume Down.
  Future<void> _runAutoVolumeSequence() async {
    final upOk = await _askForKeyDialog('Nhấn 1 lần phím Tăng âm lượng', 24, seconds: 5);
    if (upOk) {
      controller.markVolUp();
    } else {
      controller.markVolUpFailed();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final downOk = await _askForKeyDialog('Nhấn 1 lần phím Giảm âm lượng', 25, seconds: 5);
    if (downOk) {
      controller.markVolDown();
    } else {
      controller.markVolDownFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.markBackPressed();
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
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nhấn các phím vật lý để kiểm tra.\n\n'
                      'Gợi ý: Một số thiết bị Android có thể không gửi sự kiện Volume vào app. '
                      'Bạn có thể đánh dấu thủ công phím Nguồn.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _runAutoVolumeSequence,
                            child: const Text('Tự động Vol+/-', textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () => controller.startVolumeCountdown(seconds: 5),
                            child: const Text('Đếm ngược 5s', textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (controller.remainingSeconds.value > 0)
                      Card(
                        color: AppColors.AW02,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              'Vui lòng nhấn Volume + và Volume - trong ${controller.remainingSeconds.value} giây'),
                        ),
                      ),
                    KeyTile(
                      label: 'Volume +',
                      active: controller.volUp.value,
                      failed: controller.volUpFailed.value,
                      icon: Icons.volume_up_rounded,
                      action: controller.markVolUp,
                    ),
                    KeyTile(
                      label: 'Volume -',
                      active: controller.volDown.value,
                      failed: controller.volDownFailed.value,
                      icon: Icons.volume_down_rounded,
                      action: controller.markVolDown,
                    ),
                    KeyTile(
                      label: 'Back',
                      active: controller.backPressed.value,
                      icon: Icons.arrow_back_rounded,
                      action: controller.markBackPressed,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: controller.powerConfirmed.value,
                          onChanged: (v) => controller.setPowerConfirmed(v ?? false),
                        ),
                        const Expanded(
                          child: Text('Tôi đã kiểm tra phím Nguồn (không thể bắt sự kiện trực tiếp).'),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: (controller.volUp.value && controller.volDown.value)
                          ? controller.finish
                          : null,
                      child: const Text('Hoàn tất'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
