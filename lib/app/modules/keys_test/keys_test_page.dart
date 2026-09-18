import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/keys_test_constants.dart';
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
      builder:
          (ctx) => AlertDialog(
            title: Text(LocaleKeys.keys_test_plugin_not_ready_title.trans()),
            content: Text(LocaleKeys.keys_test_plugin_not_ready_content.trans()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(LocaleKeys.keys_test_ok.trans()),
              ),
            ],
          ),
    );
  }

  /// Hiện dialog yêu cầu bấm đúng `expectedKeyCode` trong `seconds`, với
  /// đếm ngược hiển thị trực tiếp trong dialog. `controller.waitForKey`
  /// đảm nhiệm việc chờ key thực tế; dialog chỉ tự đóng khi future đó
  /// hoàn tất (bấm đúng phím hoặc hết giờ) hoặc khi người dùng bấm Hủy.
  Future<bool> _askForKeyDialog(
    String title,
    int expectedKeyCode, {
    int seconds = KeysTestConstants.keyPressTimeoutSeconds,
  }) async {
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
              content: Text(
                LocaleKeys.keys_test_press_key_within_seconds.trans(
                  namedArgs: {'seconds': '$remaining'},
                ),
              ),
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
                  child: Text(LocaleKeys.keys_test_cancel.trans()),
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
    final upOk = await _askForKeyDialog(
      LocaleKeys.keys_test_press_volume_up_once.trans(),
      KeysTestConstants.androidKeyCodeVolumeUp,
      seconds: KeysTestConstants.keyPressTimeoutSeconds,
    );
    if (upOk) {
      controller.markVolUp();
    } else {
      controller.markVolUpFailed();
    }

    await Future.delayed(KeysTestConstants.autoSequenceGap);

    final downOk = await _askForKeyDialog(
      LocaleKeys.keys_test_press_volume_down_once.trans(),
      KeysTestConstants.androidKeyCodeVolumeDown,
      seconds: KeysTestConstants.keyPressTimeoutSeconds,
    );
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
        appBar: AppBar(title: Text(LocaleKeys.keys_test_title.trans())),
        body: SafeArea(
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKeyEvent,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.keys_test_instruction.trans(),
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _runAutoVolumeSequence,
                            child: Text(
                              LocaleKeys.keys_test_auto_volume.trans(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextButton(
                            onPressed:
                                () => controller.startVolumeCountdown(
                                  seconds: KeysTestConstants.keyPressTimeoutSeconds,
                                ),
                            child: Text(
                              LocaleKeys.keys_test_countdown_5s.trans(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    if (controller.remainingSeconds.value > 0)
                      Card(
                        color: AppColors.AW02,
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Text(
                            LocaleKeys.keys_test_press_volume_countdown.trans(
                              namedArgs: {
                                'seconds':
                                    '${controller.remainingSeconds.value}',
                              },
                            ),
                          ),
                        ),
                      ),
                    KeyTile(
                      label: LocaleKeys.keys_test_volume_up.trans(),
                      active: controller.volUp.value,
                      failed: controller.volUpFailed.value,
                      icon: Icons.volume_up_rounded,
                      action: controller.markVolUp,
                    ),
                    KeyTile(
                      label: LocaleKeys.keys_test_volume_down.trans(),
                      active: controller.volDown.value,
                      failed: controller.volDownFailed.value,
                      icon: Icons.volume_down_rounded,
                      action: controller.markVolDown,
                    ),
                    KeyTile(
                      label: LocaleKeys.keys_test_back.trans(),
                      active: controller.backPressed.value,
                      icon: Icons.arrow_back_rounded,
                      action: controller.markBackPressed,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Checkbox(
                          value: controller.powerConfirmed.value,
                          onChanged:
                              (v) => controller.setPowerConfirmed(v ?? false),
                        ),
                        Expanded(
                          child: Text(LocaleKeys.keys_test_power_confirm.trans()),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed:
                          (controller.volUp.value && controller.volDown.value)
                              ? controller.finish
                              : null,
                      child: Text(LocaleKeys.keys_test_finish.trans()),
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
