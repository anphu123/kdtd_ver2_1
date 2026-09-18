/// ============================================================
/// PermissionPrecheckService - Dịch Vụ Kiểm Tra Quyền Trước
/// ============================================================
///
/// File này cung cấp service để:
/// - Yêu cầu tất cả quyền cần thiết TRƯỚC khi bắt đầu test
/// - Hiển thị dialog giải thích tại sao cần mỗi quyền
/// - Tránh gián đoạn luồng test khi hỏi quyền giữa chừng
///
/// Sử dụng:
/// ```dart
/// final granted = await PermissionPrecheckService.requestAllPermissions();
/// if (granted) {
///   controller.start();
/// }
/// ```
/// ============================================================
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thông tin về một quyền cần xin
class PermissionInfo {
  /// Quyền cần xin
  final Permission permission;

  /// Icon hiển thị
  final IconData icon;

  /// Tên quyền (tiếng Việt)
  final String name;

  /// Mô tả tại sao cần quyền này
  final String description;

  /// Có bắt buộc không (nếu false, test vẫn chạy được nếu từ chối)
  final bool required;

  const PermissionInfo({
    required this.permission,
    required this.icon,
    required this.name,
    required this.description,
    this.required = false,
  });
}

/// Service quản lý việc xin quyền trước khi test
class PermissionPrecheckService {
  /// Danh sách tất cả quyền cần cho ứng dụng theo từng nền tảng
  static List<PermissionInfo> get allPermissions {
    final list = [
      PermissionInfo(
        permission: Permission.camera,
        icon: Icons.camera_alt,
        name: LocaleKeys.permission_camera_name.trans(),
        description: LocaleKeys.permission_camera_description.trans(),
        required: true,
      ),
      PermissionInfo(
        permission: Permission.microphone,
        icon: Icons.mic,
        name: LocaleKeys.permission_microphone_name.trans(),
        description: LocaleKeys.permission_microphone_description.trans(),
        required: true,
      ),
      PermissionInfo(
        permission: Permission.location,
        icon: Icons.location_on,
        name: LocaleKeys.permission_location_name.trans(),
        description: LocaleKeys.permission_location_description.trans(),
        required: false, // iOS có thể từ chối nhưng vẫn test được
      ),
    ];

    if (Platform.isAndroid) {
      list.addAll([
        PermissionInfo(
          permission: Permission.phone,
          icon: Icons.phone,
          name: LocaleKeys.permission_phone_name.trans(),
          description: LocaleKeys.permission_phone_description.trans(),
          required: false,
        ),
        PermissionInfo(
          permission: Permission.bluetoothScan,
          icon: Icons.bluetooth,
          name: LocaleKeys.permission_bluetooth_name.trans(),
          description: LocaleKeys.permission_bluetooth_description.trans(),
          required: false,
        ),
        PermissionInfo(
          permission: Permission.bluetoothConnect,
          icon: Icons.bluetooth_connected,
          name: LocaleKeys.permission_bluetooth_connect_name.trans(),
          description: LocaleKeys.permission_bluetooth_connect_description.trans(),
          required: false,
        ),
      ]);
    } else if (Platform.isIOS) {
      list.add(
        PermissionInfo(
          permission: Permission.bluetooth,
          icon: Icons.bluetooth,
          name: LocaleKeys.permission_bluetooth_name.trans(),
          description: LocaleKeys.permission_bluetooth_ios_description.trans(),
          required: false,
        ),
      );
    }

    return list;
  }

  /// Kiểm tra tất cả quyền đã được cấp chưa
  static Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final results = <Permission, PermissionStatus>{};

    for (final info in allPermissions) {
      results[info.permission] = await info.permission.status;
    }

    return results;
  }

  /// Kiểm tra xem tất cả các quyền bắt buộc đã được cấp hay chưa
  static Future<bool> hasAllRequiredPermissions() async {
    for (final info in allPermissions.where((p) => p.required)) {
      final status = await info.permission.status;
      if (!status.isGranted) return false;
    }
    return true;
  }

  /// Yêu cầu tất cả quyền (không hiển thị dialog giải thích)
  static Future<Map<Permission, bool>> requestAllPermissions() async {
    final results = <Permission, bool>{};

    for (final info in allPermissions) {
      final status = await info.permission.request();
      results[info.permission] = status.isGranted;
    }

    return results;
  }

  /// Yêu cầu quyền với dialog giải thích
  /// Trả về true nếu tất cả quyền bắt buộc đã được cấp
  static Future<bool> requestPermissionsWithExplanation() async {
    // Kiểm tra trước
    final currentStatus = await checkAllPermissions();

    // Lọc ra các quyền chưa được cấp
    final pendingPermissions =
        allPermissions.where((info) {
          final status = currentStatus[info.permission];
          return status != PermissionStatus.granted;
        }).toList();

    // Nếu tất cả đã được cấp, return true
    if (pendingPermissions.isEmpty) {
      return true;
    }

    // Hiển thị dialog giải thích
    final shouldRequest = await _showExplanationDialog(pendingPermissions);

    if (!shouldRequest) {
      return false;
    }

    // Yêu cầu các quyền
    final results = await requestAllPermissions();

    // Kiểm tra xem tất cả quyền bắt buộc đã được cấp chưa
    for (final info in allPermissions) {
      if (info.required && results[info.permission] != true) {
        // Quyền bắt buộc bị từ chối
        await _showRequiredPermissionDeniedDialog(info);
        return false;
      }
    }

    return true;
  }

  /// Hiển thị dialog giải thích tại sao cần các quyền
  static Future<bool> _showExplanationDialog(
    List<PermissionInfo> permissions,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.info),
            const SizedBox(width: 8),
            Text(LocaleKeys.permission_grant_dialog_title.trans()),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.permission_grant_dialog_intro.trans(),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...permissions.map(
                (info) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        info.icon,
                        size: 24,
                        color: AppColors.neutralGrey700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  info.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (info.required) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.failLightest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      LocaleKeys.permission_required_badge.trans(),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 10,
                                        color: AppColors.fail,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              info.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutralGreyDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(LocaleKeys.permission_deny_button.trans()),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(LocaleKeys.permission_grant_button.trans()),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Hiển thị dialog khi quyền bắt buộc bị từ chối
  static Future<void> _showRequiredPermissionDeniedDialog(
    PermissionInfo info,
  ) async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.fail),
            const SizedBox(width: 8),
            Text(LocaleKeys.permission_denied_dialog_title.trans()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.permission_denied_dialog_message.trans(
                namedArgs: {'name': info.name},
              ),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.permission_denied_dialog_purpose.trans(
                namedArgs: {'description': info.description},
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutralGreyDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.permission_denied_dialog_instruction.trans(),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocaleKeys.permission_close_button.trans()),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(LocaleKeys.permission_open_settings_button.trans()),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog nhanh về trạng thái quyền
  static Future<void> showPermissionStatusDialog() async {
    final statuses = await checkAllPermissions();

    await Get.dialog(
      AlertDialog(
        title: Text(LocaleKeys.permission_status_dialog_title.trans()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                allPermissions.map((info) {
                  final status = statuses[info.permission];
                  final isGranted = status == PermissionStatus.granted;

                  return ListTile(
                    leading: Icon(
                      info.icon,
                      color: isGranted ? AppColors.pass : AppColors.fail,
                    ),
                    title: Text(info.name),
                    trailing: Icon(
                      isGranted ? Icons.check_circle : Icons.cancel,
                      color: isGranted ? AppColors.pass : AppColors.fail,
                    ),
                  );
                }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocaleKeys.permission_close_button.trans()),
          ),
        ],
      ),
    );
  }
}
