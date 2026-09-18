import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

import 'mic_test_controller.dart';

/// Nhãn/màu/icon hiển thị (đã dịch) cho [MicTestPhase] - tách khỏi UI của MicTestPage.
extension MicTestPhaseLabel on MicTestPhase {
  String get instructionText {
    switch (this) {
      case MicTestPhase.recording:
        return LocaleKeys.mic_test_instruction_recording.trans();
      case MicTestPhase.playing:
        return LocaleKeys.mic_test_instruction_playing.trans();
      case MicTestPhase.confirming:
        return LocaleKeys.mic_test_instruction_confirming.trans();
    }
  }

  Color phaseColor(bool hasDetectedSound) {
    switch (this) {
      case MicTestPhase.recording:
        return hasDetectedSound ? AppColors.pass : AppColors.info;
      case MicTestPhase.playing:
        return AppColors.warning;
      case MicTestPhase.confirming:
        return AppColors.neutralPurple;
    }
  }

  IconData phaseIcon(bool hasDetectedSound) {
    switch (this) {
      case MicTestPhase.recording:
        return hasDetectedSound ? Icons.check_circle : Icons.mic;
      case MicTestPhase.playing:
        return Icons.volume_up;
      case MicTestPhase.confirming:
        return Icons.help_outline;
    }
  }

  String phaseStatus(bool hasDetectedSound) {
    switch (this) {
      case MicTestPhase.recording:
        return hasDetectedSound
            ? LocaleKeys.mic_test_status_sound_detected.trans()
            : LocaleKeys.mic_test_status_listening.trans();
      case MicTestPhase.playing:
        return LocaleKeys.mic_test_status_playing.trans();
      case MicTestPhase.confirming:
        return LocaleKeys.mic_test_status_waiting_confirm.trans();
    }
  }
}
