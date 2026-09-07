/// ============================================================
/// StatusInfo - Thông Tin Trạng Thái Test
/// ============================================================
///
/// File này cung cấp các helper function để:
/// - Lấy màu sắc, icon, label tương ứng với DiagStatus
/// - Lấy icon tương ứng với từng loại test
///
/// Được sử dụng bởi các widget hiển thị kết quả test.
/// ============================================================
library;

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';

/// Thông tin trạng thái để hiển thị UI
class StatusInfo {
  /// Màu sắc đặc trưng cho trạng thái
  final Color color;

  /// Icon đặc trưng cho trạng thái
  final IconData icon;

  /// Nhãn hiển thị (tiếng Việt)
  final String label;

  /// Nhãn hiển thị tiếng Anh
  final String labelEn;

  const StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
    required this.labelEn,
  });
}

/// Lấy thông tin trạng thái từ DiagStatus
StatusInfo getStatusInfo(DiagStatus status) {
  switch (status) {
    case DiagStatus.passed:
      return const StatusInfo(
        color: AppColors.green03B134,
        icon: Icons.check_circle,
        label: 'Đạt',
        labelEn: 'Passed',
      );
    case DiagStatus.failed:
      return const StatusInfo(
        color: AppColors.redE82B2B,
        icon: Icons.cancel,
        label: 'Lỗi',
        labelEn: 'Failed',
      );
    case DiagStatus.running:
      return const StatusInfo(
        color: AppColors.yellowFEA400,
        icon: Icons.autorenew,
        label: 'Đang chạy',
        labelEn: 'Running',
      );
    case DiagStatus.skipped:
      return const StatusInfo(
        color: AppColors.gray969696,
        icon: Icons.remove_circle_outline,
        label: 'Bỏ qua',
        labelEn: 'Skipped',
      );
    case DiagStatus.pending:
      return const StatusInfo(
        color: AppColors.blue006FFD,
        icon: Icons.play_circle_outline,
        label: 'Chờ',
        labelEn: 'Pending',
      );
  }
}

/// Lấy icon tương ứng với mã test
IconData getTestIcon(String code) {
  switch (code) {
    // === THÔNG TIN HỆ THỐNG ===
    case 'osmodel':
      return Icons.phone_android;
    case 'battery':
      return Icons.battery_full;
    case 'ram':
      return Icons.memory;
    case 'rom':
      return Icons.storage;

    // === KẾT NỐI ===
    case 'wifi':
      return Icons.wifi;
    case 'mobile':
      return Icons.signal_cellular_4_bar;
    case 'bt':
      return Icons.bluetooth;
    case 'nfc':
      return Icons.nfc;
    case 'sim':
      return Icons.sim_card;

    // === CẢM BIẾN ===
    case 'sensors':
      return Icons.sensors;
    case 'gps':
      return Icons.gps_fixed;
    case 'bio':
      return Icons.fingerprint;

    // === PHẦN CỨNG ===
    case 'charge':
      return Icons.power;
    case 'wired':
      return Icons.headphones;
    case 'lock':
      return Icons.lock;
    case 'spen':
      return Icons.brush;
    case 'vibrate':
      return Icons.vibration;

    // === MÀN HÌNH ===
    case 'screen':
      return Icons.smartphone;
    case 'touch':
      return Icons.touch_app;

    // === TEST THỦ CÔNG ===
    case 'camera':
      return Icons.camera_alt;
    case 'speaker':
      return Icons.volume_up;
    case 'mic':
      return Icons.mic;
    case 'ear':
      return Icons.hearing;
    case 'keys':
      return Icons.keyboard;

    default:
      return Icons.check_box_outline_blank;
  }
}

/// Lấy tiêu đề tiếng Việt cho test code
String getTestTitle(String code) {
  switch (code) {
    case 'osmodel':
      return 'Thông tin thiết bị';
    case 'battery':
      return 'Pin & Sạc';
    case 'ram':
      return 'Bộ nhớ RAM';
    case 'rom':
      return 'Bộ nhớ ROM';
    case 'wifi':
      return 'Wi-Fi';
    case 'mobile':
      return 'Mạng di động';
    case 'bt':
      return 'Bluetooth';
    case 'nfc':
      return 'NFC';
    case 'sim':
      return 'Thẻ SIM';
    case 'sensors':
      return 'Cảm biến';
    case 'gps':
      return 'Định vị GPS';
    case 'bio':
      return 'Sinh trắc học';
    case 'charge':
      return 'Nguồn sạc';
    case 'wired':
      return 'Tai nghe có dây';
    case 'lock':
      return 'Khóa màn hình';
    case 'spen':
      return 'S-Pen';
    case 'vibrate':
      return 'Rung';
    case 'screen':
      return 'Màn hình';
    case 'touch':
      return 'Cảm ứng';
    case 'camera':
      return 'Camera';
    case 'speaker':
      return 'Loa ngoài';
    case 'mic':
      return 'Microphone';
    case 'ear':
      return 'Loa trong';
    case 'keys':
      return 'Phím vật lý';
    default:
      return code;
  }
}
