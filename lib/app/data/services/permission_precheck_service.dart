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
import 'package:get/get.dart';
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
      const PermissionInfo(
        permission: Permission.camera,
        icon: Icons.camera_alt,
        name: 'Camera',
        description: 'Kiểm tra camera trước và sau',
        required: true,
      ),
      const PermissionInfo(
        permission: Permission.microphone,
        icon: Icons.mic,
        name: 'Microphone',
        description: 'Kiểm tra microphone thu âm',
        required: true,
      ),
      const PermissionInfo(
        permission: Permission.location,
        icon: Icons.location_on,
        name: 'Vị trí',
        description: 'Kiểm tra GPS và đọc SSID WiFi',
        required: false, // iOS có thể từ chối nhưng vẫn test được
      ),
    ];

    if (Platform.isAndroid) {
      list.addAll([
        const PermissionInfo(
          permission: Permission.phone,
          icon: Icons.phone,
          name: 'Điện thoại',
          description: 'Đọc IMEI, thông tin SIM',
          required: false,
        ),
        const PermissionInfo(
          permission: Permission.bluetoothScan,
          icon: Icons.bluetooth,
          name: 'Bluetooth',
          description: 'Kiểm tra Bluetooth scan',
          required: false,
        ),
        const PermissionInfo(
          permission: Permission.bluetoothConnect,
          icon: Icons.bluetooth_connected,
          name: 'Bluetooth Connect',
          description: 'Kết nối Bluetooth',
          required: false,
        ),
      ]);
    } else if (Platform.isIOS) {
      list.add(
        const PermissionInfo(
          permission: Permission.bluetooth,
          icon: Icons.bluetooth,
          name: 'Bluetooth',
          description: 'Kiểm tra kết nối Bluetooth',
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
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.info),
            SizedBox(width: 8),
            Text('Cấp Quyền Để Kiểm Định'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ứng dụng cần các quyền sau để kiểm định chính xác:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...permissions.map(
                (info) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(info.icon, size: 24, color: AppColors.neutralGrey700),
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
                                      'Bắt buộc',
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
            child: const Text('Từ chối'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đồng ý cấp quyền'),
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
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.fail),
            SizedBox(width: 8),
            Text('Không Thể Tiếp Tục'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quyền "${info.name}" là bắt buộc để kiểm định.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Mục đích: ${info.description}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralGreyDark),
            ),
            const SizedBox(height: 16),
            Text(
              'Vui lòng vào Cài đặt > Ứng dụng > Quyền để cấp quyền.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
          FilledButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
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
        title: const Text('Trạng Thái Quyền'),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
        ],
      ),
    );
  }
}
