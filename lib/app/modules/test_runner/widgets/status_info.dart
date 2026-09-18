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
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';

import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Thông tin trạng thái để hiển thị UI (100% Solid Pure Colors)
class StatusInfo {
  /// Màu sắc đặc trưng cho trạng thái
  final Color color;

  /// Màu nền thuần cho trạng thái
  final Color surfaceColor;

  /// Màu viền thuần cho trạng thái
  final Color borderColor;

  /// Icon đặc trưng cho trạng thái
  final IconData icon;

  /// Nhãn hiển thị (tiếng Việt)
  final String label;

  /// Nhãn hiển thị tiếng Anh
  final String labelEn;

  const StatusInfo({
    required this.color,
    required this.surfaceColor,
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.labelEn,
  });
}

/// Lấy thông tin trạng thái từ DiagStatus
StatusInfo getStatusInfo(DiagStatus status) {
  switch (status) {
    case DiagStatus.passed:
      return StatusInfo(
        color: AppColors.success,
        surfaceColor: AppColors.successSurface,
        borderColor: AppColors.successBorder,
        icon: Icons.check_circle,
        label: LocaleKeys.diagnostics_home_status_label_passed.trans(),
        labelEn: 'Passed',
      );
    case DiagStatus.failed:
      return StatusInfo(
        color: AppColors.error,
        surfaceColor: AppColors.errorSurface,
        borderColor: AppColors.errorBorder,
        icon: Icons.cancel,
        label: LocaleKeys.diagnostics_home_status_label_failed.trans(),
        labelEn: 'Failed',
      );
    case DiagStatus.running:
      return StatusInfo(
        color: AppColors.warning,
        surfaceColor: AppColors.warningSurface,
        borderColor: AppColors.warningBorder,
        icon: Icons.autorenew,
        label: LocaleKeys.diagnostics_home_status_label_running.trans(),
        labelEn: 'Running',
      );
    case DiagStatus.skipped:
      return StatusInfo(
        color: AppColors.neutralGreyDark,
        surfaceColor: AppColors.neutralGreyLight,
        borderColor: AppColors.neutralGreyLighter,
        icon: Icons.remove_circle_outline,
        label: LocaleKeys.diagnostics_home_status_label_skipped.trans(),
        labelEn: 'Skipped',
      );
    case DiagStatus.pending:
      return StatusInfo(
        color: AppColors.pviBlue,
        surfaceColor: AppColors.pviBlueSurface,
        borderColor: AppColors.pviBlueBorder,
        icon: Icons.play_circle_outline,
        label: LocaleKeys.diagnostics_home_status_label_pending.trans(),
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

    // === KIỂM TRA THỦ CÔNG ===
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
      return LocaleKeys.diagnostics_home_test_title_osmodel.trans();
    case 'battery':
      return LocaleKeys.diagnostics_home_test_title_battery.trans();
    case 'ram':
      return LocaleKeys.diagnostics_home_test_title_ram.trans();
    case 'rom':
      return LocaleKeys.diagnostics_home_test_title_rom.trans();
    case 'wifi':
      return LocaleKeys.diagnostics_home_test_title_wifi.trans();
    case 'mobile':
      return LocaleKeys.diagnostics_home_test_title_mobile.trans();
    case 'bt':
      return LocaleKeys.diagnostics_home_test_title_bt.trans();
    case 'nfc':
      return LocaleKeys.diagnostics_home_test_title_nfc.trans();
    case 'sim':
      return LocaleKeys.diagnostics_home_test_title_sim.trans();
    case 'sensors':
      return LocaleKeys.diagnostics_home_test_title_sensors.trans();
    case 'gps':
      return LocaleKeys.diagnostics_home_test_title_gps.trans();
    case 'bio':
      return LocaleKeys.diagnostics_home_test_title_bio.trans();
    case 'charge':
      return LocaleKeys.diagnostics_home_test_title_charge.trans();
    case 'wired':
      return LocaleKeys.diagnostics_home_test_title_wired.trans();
    case 'lock':
      return LocaleKeys.diagnostics_home_test_title_lock.trans();
    case 'spen':
      return LocaleKeys.diagnostics_home_test_title_spen.trans();
    case 'vibrate':
      return LocaleKeys.diagnostics_home_test_title_vibrate.trans();
    case 'screen':
      return LocaleKeys.diagnostics_home_test_title_screen.trans();
    case 'touch':
      return LocaleKeys.diagnostics_home_test_title_touch.trans();
    case 'camera':
      return LocaleKeys.diagnostics_home_test_title_camera.trans();
    case 'speaker':
      return LocaleKeys.diagnostics_home_test_title_speaker.trans();
    case 'mic':
      return LocaleKeys.diagnostics_home_test_title_mic.trans();
    case 'ear':
      return LocaleKeys.diagnostics_home_test_title_ear.trans();
    case 'keys':
      return LocaleKeys.diagnostics_home_test_title_keys.trans();
    default:
      return code;
  }
}
