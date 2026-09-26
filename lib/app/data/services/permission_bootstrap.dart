import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

/// Trạng thái thiết lập quyền lúc khởi động.
enum PermissionBootstrapStatus {
  /// Chưa chạy.
  idle,

  /// Đang lần lượt xin từng quyền.
  requesting,

  /// Đã đủ mọi quyền bắt buộc — vào là chạy được ngay.
  ready,

  /// Thiếu ít nhất một quyền bắt buộc — phải qua màn Cấp quyền.
  needsAttention,
}

/// Xin toàn bộ quyền ngay khi mở app, để lúc bắt đầu kiểm định thì mọi thứ
/// đã sẵn sàng và bỏ qua được hẳn màn Cấp quyền.
///
/// Trước đây quyền chỉ được xin ở màn Cấp quyền, nằm giữa luồng (sau bước
/// nhập serial). Kỹ thuật viên phải dừng lại bấm từng cái mỗi lần kiểm
/// định máy mới — trong khi quyền đã cấp thì hệ điều hành nhớ vĩnh viễn,
/// chỉ cần hỏi đúng MỘT lần sau khi cài app.
///
/// LƯU Ý: hộp thoại xin quyền là của hệ điều hành, không thể chạy ngầm hoàn
/// toàn — lần đầu cài vẫn phải bấm "Cho phép". Những lần mở sau thì mọi
/// quyền đã được cấp, bước này chạy xong tức thì không hiện gì.
class PermissionBootstrap {
  PermissionBootstrap._();

  static final status = PermissionBootstrapStatus.idle.obs;

  /// Quyền bắt buộc: thiếu thì bài test tương ứng không chạy được.
  ///
  /// Giữ khớp với các mục `isRequired: true` trong PermissionCheckController
  /// (màn Cấp quyền dự phòng).
  static const List<Permission> _required = [
    Permission.camera,
    Permission.microphone,
  ];

  /// Quyền tuỳ chọn: thiếu thì bài test tương ứng tự skip, không chặn luồng.
  ///
  /// Không có BLUETOOTH_CONNECT: bài test Bluetooth chỉ QUÉT, không kết nối,
  /// nên Android 12+ chỉ cần BLUETOOTH_SCAN. Xin thừa chỉ tổ thêm một hộp
  /// thoại cho kỹ thuật viên phải bấm.
  static List<Permission> get _optional => [
    // Vị trí: GPS, và đọc tên Wi-Fi (SSID) trên cả hai nền tảng.
    Permission.location,
    if (Platform.isIOS) Permission.bluetooth,
    if (Platform.isAndroid) Permission.bluetoothScan,
  ];

  static Future<void>? _running;

  /// Xin lần lượt mọi quyền chưa được cấp. Gọi nhiều lần cũng chỉ chạy một
  /// lượt — lần gọi sau nhận lại đúng Future đang chạy.
  static Future<void> requestAllAtLaunch() {
    return _running ??= _requestAll();
  }

  static Future<void> _requestAll() async {
    status.value = PermissionBootstrapStatus.requesting;

    // Tuần tự, không song song: mỗi lúc hệ điều hành chỉ hiện được một hộp
    // thoại quyền. Xin quyền bắt buộc trước để nếu người dùng bỏ ngang giữa
    // chừng thì phần quan trọng nhất đã xong.
    for (final permission in [..._required, ..._optional]) {
      try {
        final current = await permission.status;
        // Đã cấp, hoặc đã từ chối vĩnh viễn (gọi request() cũng không hiện
        // hộp thoại nữa) thì bỏ qua.
        if (current.isGranted ||
            current.isLimited ||
            current.isPermanentlyDenied) {
          continue;
        }
        final result = await permission.request();
        debugPrint('[PermissionBootstrap] $permission -> $result');
      } catch (e) {
        // Một quyền lỗi (vd nền tảng không hỗ trợ) không được chặn các
        // quyền còn lại.
        debugPrint('[PermissionBootstrap] Lỗi xin $permission: $e');
      }
    }

    status.value =
        await allRequiredGranted()
            ? PermissionBootstrapStatus.ready
            : PermissionBootstrapStatus.needsAttention;
    debugPrint('[PermissionBootstrap] Hoàn tất: ${status.value}');
  }

  /// Đã đủ mọi quyền bắt buộc chưa.
  ///
  /// KHÔNG được ném lỗi: nó chạy ở cuối [_requestAll], mà nếu [_requestAll]
  /// lỗi thì [_running] giữ một Future lỗi vĩnh viễn — mọi lần bấm "Bắt đầu"
  /// sau đó `await _running` rồi ném theo, người dùng đứng im không vào được.
  /// Đọc không được trạng thái thì coi như chưa cấp: rơi về màn Cấp quyền là
  /// lối thoát an toàn.
  static Future<bool> allRequiredGranted() async {
    try {
      for (final permission in _required) {
        if (!await permission.isGranted) return false;
      }
      return true;
    } catch (e) {
      debugPrint('[PermissionBootstrap] Không đọc được trạng thái quyền: $e');
      return false;
    }
  }

  /// Đi tiếp vào kiểm định sau bước nhập serial.
  ///
  /// Đủ quyền bắt buộc thì bỏ qua màn Cấp quyền, quét cấu hình và vào chạy
  /// test luôn. Thiếu thì mới rơi về màn Cấp quyền để kỹ thuật viên xử lý.
  static Future<void> continueToDiagnostics() async {
    // Nếu lượt xin quyền lúc khởi động còn đang chạy thì đợi nó xong trước,
    // tránh kết luận "thiếu quyền" chỉ vì hộp thoại chưa kịp được bấm.
    await _running;

    if (!await allRequiredGranted()) {
      Get.toNamed(AppRoutes.permissionCheck);
      return;
    }

    final home =
        Get.isRegistered<DiagnosticsHomeController>()
            ? Get.find<DiagnosticsHomeController>()
            : Get.put(DiagnosticsHomeController());
    await home.startCriticalScanAndConfirm();
  }
}
