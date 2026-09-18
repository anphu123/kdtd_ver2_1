import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';

/// Nhãn hiển thị (đã dịch) cho [DiagStatus] - tách khỏi UI của DiagnosticsHome.
extension DiagStatusLabel on DiagStatus {
  String get label {
    switch (this) {
      case DiagStatus.passed:
        return LocaleKeys.diagnostics_home_status_passed.trans();
      case DiagStatus.failed:
        return LocaleKeys.diagnostics_home_status_failed.trans();
      case DiagStatus.running:
        return LocaleKeys.diagnostics_home_status_running.trans();
      case DiagStatus.skipped:
        return LocaleKeys.diagnostics_home_status_skipped.trans();
      case DiagStatus.pending:
        return LocaleKeys.diagnostics_home_status_pending.trans();
    }
  }
}

/// Nhãn hiển thị (đã dịch) cho tiêu đề mỗi [DiagPhase].
extension DiagPhaseLabel on DiagPhase {
  String get title {
    switch (this) {
      case DiagPhase.critical:
        return LocaleKeys.diagnostics_home_phase_title_critical.trans();
      case DiagPhase.connectivity:
        return LocaleKeys.diagnostics_home_phase_title_connectivity.trans();
      case DiagPhase.sensors:
        return LocaleKeys.diagnostics_home_phase_title_sensors.trans();
      case DiagPhase.hardware:
        return LocaleKeys.diagnostics_home_phase_title_hardware.trans();
      case DiagPhase.screen:
        return LocaleKeys.diagnostics_home_phase_title_screen.trans();
      case DiagPhase.manual:
        return LocaleKeys.diagnostics_home_phase_title_manual.trans();
    }
  }
}
