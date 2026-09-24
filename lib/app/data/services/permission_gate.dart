import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:permission_handler/permission_handler.dart';

/// Cổng xin quyền dùng chung cho mọi bài test.
///
/// Quyền bị từ chối → xin thêm một lần (Android còn hiện được hộp thoại hệ
/// thống); vẫn từ chối → hỏi kỹ thuật viên có muốn sang Cài đặt bật lên không.
/// Không bật được thì trả `false` để bài test đánh trượt.
class PermissionGate {
  PermissionGate._();

  static Future<bool> ensure(Permission permission, {required String name}) async {
    var status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;

    // Android: từ chối lần đầu chưa vĩnh viễn nên còn xin lại được. iOS chỉ
    // hiện hộp thoại đúng một lần, request lần hai trả về `denied` ngay.
    if (Platform.isAndroid && !status.isPermanentlyDenied) {
      status = await permission.request();
      if (status.isGranted) return true;
    }

    final openSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text(LocaleKeys.permission_gate_title.trans()),
        content: Text(
          LocaleKeys.permission_gate_message.trans(namedArgs: {'name': name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(LocaleKeys.permission_deny_button.trans()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(LocaleKeys.permission_gate_open_settings.trans()),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (openSettings != true) return false;

    await _openSettingsAndWaitForReturn();
    return permission.status.isGranted;
  }

  static Future<void> _openSettingsAndWaitForReturn() async {
    final completer = Completer<void>();
    final observer = _ResumeObserver(() {
      if (!completer.isCompleted) completer.complete();
    });
    WidgetsBinding.instance.addObserver(observer);
    try {
      await openAppSettings();
      await completer.future;
    } finally {
      WidgetsBinding.instance.removeObserver(observer);
    }
  }
}

class _ResumeObserver extends WidgetsBindingObserver {
  _ResumeObserver(this.onResumed);

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
