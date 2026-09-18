import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:permission_handler/permission_handler.dart';

/// Item đại diện cho một quyền cần cấp
class PermissionCheckItem {
  final Permission permission;
  final IconData icon;
  final String name;
  final String description;
  final bool isRequired;
  final Color accentColor;
  final Color surfaceColor;
  final Rx<PermissionStatus> status;

  PermissionCheckItem({
    required this.permission,
    required this.icon,
    required this.name,
    required this.description,
    this.isRequired = false,
    this.accentColor = AppColors.pviRed,
    this.surfaceColor = AppColors.pviRedSurface,
    PermissionStatus initialStatus = PermissionStatus.denied,
  }) : status = initialStatus.obs;

  bool get isGranted => status.value.isGranted;
  bool get isPermanentlyDenied => status.value.isPermanentlyDenied;
}

class PermissionCheckController extends GetxController
    with WidgetsBindingObserver {
  final isChecking = false.obs;
  final isRequestingAll = false.obs;
  final items = <PermissionCheckItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initPermissionItems();
    refreshStatuses();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[PermissionCheck] App resumed - Tự động đồng bộ lại trạng thái quyền...');
      refreshStatuses();
    }
  }

  void _initPermissionItems() {
    final list = <PermissionCheckItem>[
      PermissionCheckItem(
        permission: Permission.camera,
        icon: Icons.camera_alt_rounded,
        name: 'Máy ảnh (Camera)',
        description:
            'Cần để kiểm tra cụm camera trước, camera sau, ống kính góc rộng, macro và flash.',
        isRequired: true,
        accentColor: AppColors.pviRed,
        surfaceColor: AppColors.pviRedSurface,
      ),
      PermissionCheckItem(
        permission: Permission.microphone,
        icon: Icons.mic_rounded,
        name: 'Microphone & Thu âm',
        description:
            'Cần để kiểm tra màng mic thoại, mic phụ khử ồn và thu âm kiểm tra loa.',
        isRequired: true,
        accentColor: AppColors.pviNavy,
        surfaceColor: AppColors.pviNavySurface,
      ),
      PermissionCheckItem(
        permission: Permission.location,
        icon: Icons.location_on_rounded,
        name: 'Vị trí & GPS',
        description:
            'Hỗ trợ kiểm tra ăng-ten GPS đa vệ tinh và hỗ trợ quét mạng Wi-Fi lân cận.',
        isRequired: false,
        accentColor: AppColors.warning,
        surfaceColor: AppColors.warningSurface,
      ),
    ];

    if (Platform.isAndroid) {
      list.addAll([
        PermissionCheckItem(
          permission: Permission.phone,
          icon: Icons.phone_in_talk_rounded,
          name: 'Điện thoại & Khay SIM',
          description:
              'Kiểm tra khả năng nhận diện khay SIM vật lý và trạng thái sóng mạng viễn thông.',
          isRequired: false,
          accentColor: AppColors.pviBlue,
          surfaceColor: AppColors.pviBlueSurface,
        ),
        PermissionCheckItem(
          permission: Permission.bluetoothScan,
          icon: Icons.bluetooth_searching_rounded,
          name: 'Quét Bluetooth',
          description:
              'Kiểm tra khả năng quét và nhận diện các thiết bị Bluetooth xung quanh.',
          isRequired: false,
          accentColor: AppColors.success,
          surfaceColor: AppColors.successSurface,
        ),
        PermissionCheckItem(
          permission: Permission.bluetoothConnect,
          icon: Icons.bluetooth_connected_rounded,
          name: 'Kết nối Bluetooth',
          description:
              'Kiểm tra chip Bluetooth nội bộ và giao thức kết nối phụ kiện.',
          isRequired: false,
          accentColor: AppColors.success,
          surfaceColor: AppColors.successSurface,
        ),
      ]);
    } else if (Platform.isIOS) {
      list.add(
        PermissionCheckItem(
          permission: Permission.bluetooth,
          icon: Icons.bluetooth_rounded,
          name: 'Bluetooth',
          description:
              'Kiểm tra chip Bluetooth nội bộ và khả năng tương tác phụ kiện.',
          isRequired: false,
          accentColor: AppColors.success,
          surfaceColor: AppColors.successSurface,
        ),
      );
    }

    items.assignAll(list);
  }

  /// Cập nhật trạng thái của tất cả các quyền
  Future<void> refreshStatuses() async {
    isChecking.value = true;
    for (final item in items) {
      try {
        final currentStatus = await item.permission.status;
        item.status.value = currentStatus;
      } catch (e) {
        debugPrint('[PermissionCheck] Lỗi kiểm tra quyền ${item.name}: $e');
      }
    }
    isChecking.value = false;
    _logStatusResponse('PERMISSION_STATUS_REFRESH');
  }

  /// Yêu cầu 1 quyền cụ thể
  Future<void> requestSingle(PermissionCheckItem item) async {
    if (item.isGranted) return;

    try {
      final res = await item.permission.request();
      item.status.value = res;
      _logStatusResponse('PERMISSION_REQUEST_SINGLE: ${item.name}');

      if (res.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(item);
      }
    } catch (e) {
      debugPrint('[PermissionCheck] Lỗi xin quyền ${item.name}: $e');
    }
  }

  /// Yêu cầu tất cả các quyền chưa được cấp
  Future<void> requestAll() async {
    if (isRequestingAll.value) return;
    isRequestingAll.value = true;

    try {
      for (final item in items) {
        if (!item.isGranted) {
          final res = await item.permission.request();
          item.status.value = res;
        }
      }
      _logStatusResponse('PERMISSION_REQUEST_ALL');

      // Nếu có quyền bắt buộc bị từ chối vĩnh viễn
      final permanentlyDeniedRequired = items.firstWhereOrNull(
        (e) => e.isRequired && e.isPermanentlyDenied,
      );
      if (permanentlyDeniedRequired != null) {
        _showPermanentlyDeniedDialog(permanentlyDeniedRequired);
      }
    } finally {
      isRequestingAll.value = false;
    }
  }

  /// Mở trang cài đặt ứng dụng
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Người dùng bấm nút tiếp tục kiểm định
  Future<void> proceedToDiagnostics() async {
    if (!allRequiredGranted) {
      Get.snackbar(
        'Cần Cấp Quyền Bắt Buộc',
        'Vui lòng cấp quyền Camera và Micro để tiếp tục kiểm định các linh kiện phần cứng.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.tradeInNavy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.tradeInGold),
      );
      return;
    }

    _logStatusResponse('PERMISSION_PROCEED_TO_DIAGNOSTICS');

    // Chuyển sang quét cấu hình & xác nhận
    if (Get.isRegistered<DiagnosticsHomeController>()) {
      await Get.find<DiagnosticsHomeController>().startCriticalScanAndConfirm();
    } else {
      final homeCtrl = Get.put(DiagnosticsHomeController());
      await homeCtrl.startCriticalScanAndConfirm();
    }
  }

  // ==================== CÁC PHƯƠNG THỨC GETTER ====================

  /// Đã cấp đủ các quyền bắt buộc chưa (Camera & Mic)
  bool get allRequiredGranted =>
      items.where((e) => e.isRequired).every((e) => e.isGranted);

  /// Đã cấp tất cả các quyền chưa
  bool get allGranted => items.every((e) => e.isGranted);

  /// Số lượng quyền đã cấp
  int get grantedCount => items.where((e) => e.isGranted).length;

  /// Tổng số quyền
  int get totalCount => items.length;

  /// Tỷ lệ phần trăm đã cấp (0.0 -> 1.0)
  double get progressRatio =>
      totalCount > 0 ? (grantedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  // ==================== GHI NHẬT KÝ & HỘP THOẠI ====================

  void _logStatusResponse(String eventName) {
    final response = {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'all_required_granted': allRequiredGranted,
      'all_granted': allGranted,
      'granted_count': grantedCount,
      'total_count': totalCount,
      'permissions': items.map((e) => {
            'name': e.name,
            'required': e.isRequired,
            'status': e.status.value.toString().split('.').last,
          }).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('[PermissionCheck] 📥 PERMISSION_STATUS_RESPONSE:\n${encoder.convert(response)}');
  }

  void _showPermanentlyDeniedDialog(PermissionCheckItem item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.settings_suggest_rounded,
                color: AppColors.tradeInGold, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Cần Mở Cài Đặt',
                style: AppTextStyles.cardTitle,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quyền "${item.name}" đã bị từ chối vĩnh viễn trên thiết bị. Để tiếp tục bài kiểm tra, bạn cần kích hoạt trong cài đặt hệ thống.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.tradeInDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tradeInSurfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.tradeInBorder),
              ),
              child: Text(
                item.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.tradeInSlate,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Để Sau',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.tradeInSlateLight,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Get.back();
              openSettings();
            },
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('Mở Cài Đặt'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tradeInNavy,
            ),
          ),
        ],
      ),
    );
  }
}
