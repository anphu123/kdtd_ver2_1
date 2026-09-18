import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/audio_test_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Các giai đoạn của bài test micro.
enum MicTestPhase {
  recording, // Đang thu âm 5 giây
  playing, // Đang phát lại
  confirming, // Chờ người dùng xác nhận
}

/// ============================================================
/// MicTestController - Logic Bài Test Micro
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test micro (xin quyền, thu âm 5 giây với
/// theo dõi biên độ, phát lại, xử lý vòng đời ứng dụng) sống ở đây; trang
/// (`MicTestPage`) chỉ còn là UI thuần đọc các field `.obs` qua `Obx`.
class MicTestController extends GetxController {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Amplitude>? _sub;
  StreamSubscription<void>? _playerCompleteSub;
  String? _recordingPath;
  Timer? _countdownTimer;

  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final phase = MicTestPhase.recording.obs;
  final amplitude = 0.0.obs;
  final maxAmplitude = 0.0.obs;
  final ready = false.obs;
  final hasDetectedSound = false.obs;
  final error = Rx<String?>(null);
  final amplitudeHistory = <double>[].obs;
  final countdown = 5.obs;

  @override
  void onInit() {
    super.onInit();
    // Setup player complete listener một lần duy nhất.
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      phase.value = MicTestPhase.confirming;
    });
    start();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _playerCompleteSub?.cancel();
    _player.dispose();
    _disposeRecording();
    super.onClose();
  }

  // ==================== VÒNG ĐỜI (TẠM DỪNG / TIẾP TỤC ỨNG DỤNG) ====================

  /// Ứng dụng bị đưa xuống nền — dừng thu âm để tránh giữ tài nguyên.
  Future<void> onAppPaused() async {
    await _disposeRecording();
    ready.value = false;
  }

  /// Ứng dụng quay lại foreground — khởi động lại bài test từ đầu.
  void onAppResumed() {
    start();
  }

  // ==================== KHỞI TẠO & BẮT ĐẦU TEST ====================

  /// Khởi động (hoặc khởi động lại) toàn bộ bài test micro.
  Future<void> start() async {
    phase.value = MicTestPhase.recording;
    amplitude.value = 0.0;
    maxAmplitude.value = 0.0;
    ready.value = false;
    hasDetectedSound.value = false;
    error.value = null;
    amplitudeHistory.clear();
    countdown.value = AudioTestConstants.micRecordingSeconds;

    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        error.value = LocaleKeys.mic_test_error_no_permission.trans();
        return;
      }

      final ok = await _rec.hasPermission();
      if (!ok) {
        error.value = LocaleKeys.mic_test_error_recording_permission.trans();
        return;
      }

      if (await _rec.isRecording()) {
        await _rec.stop();
      }

      // Tạo đường dẫn tệp tạm thời cho bản ghi âm
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/mic_test_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Bắt đầu ghi âm và theo dõi biên độ âm thanh
      await _rec.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: AudioTestConstants.recordingBitRate,
          sampleRate: AudioTestConstants.recordingSampleRate,
          numChannels: AudioTestConstants.recordingChannels,
        ),
        path: _recordingPath!,
      );

      await _sub?.cancel();
      _sub = _rec
          .onAmplitudeChanged(AudioTestConstants.amplitudeSampleInterval)
          .listen(
            (a) {
              final currentAmp = a.current.abs();

              // Lưu lịch sử amplitude cho waveform
              amplitudeHistory.add(currentAmp);
              if (amplitudeHistory.length >
                  AudioTestConstants.amplitudeHistoryMaxLength) {
                amplitudeHistory.removeAt(0);
              }

              amplitude.value = currentAmp;
              if (currentAmp > maxAmplitude.value) {
                maxAmplitude.value = currentAmp;
              }
              // Phát hiện âm thanh
              if (currentAmp > AudioTestConstants.soundDetectionAmplitudeThreshold) {
                hasDetectedSound.value = true;
              }
            },
            onError: (e) {
              error.value = LocaleKeys.mic_test_error_amplitude.trans(
                namedArgs: {'error': '$e'},
              );
            },
          );

      ready.value = true;

      // Bắt đầu countdown 5 giây
      _startRecordingCountdown();
    } catch (e) {
      error.value = LocaleKeys.mic_test_error_start_mic.trans(
        namedArgs: {'error': '$e'},
      );
    }
  }

  void _startRecordingCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = countdown.value - 1;
      countdown.value = next;

      if (next <= 0) {
        timer.cancel();
        _stopRecordingAndPlayback();
      }
    });
  }

  Future<void> _stopRecordingAndPlayback() async {
    try {
      // Dừng thu âm
      await _sub?.cancel();
      _sub = null;

      if (await _rec.isRecording()) {
        await _rec.stop();
      }

      // Chuyển sang phase phát lại
      phase.value = MicTestPhase.playing;

      // Phát lại file đã thu
      if (_recordingPath != null && await File(_recordingPath!).exists()) {
        await _player.play(DeviceFileSource(_recordingPath!));
        // Listener đã được setup trong onInit, sẽ tự động chuyển phase
      } else {
        // Không có file, chuyển thẳng sang confirming
        phase.value = MicTestPhase.confirming;
      }
    } catch (e) {
      error.value = LocaleKeys.mic_test_error_playback.trans(
        namedArgs: {'error': '$e'},
      );
      phase.value = MicTestPhase.confirming;
    }
  }

  /// Kết thúc bài test — pop kết quả về màn hình trước.
  void finish(bool passed) => Get.back(result: passed);

  /// Mức âm lượng đã chuẩn hoá (0.0 - 1.0) để hiển thị animation.
  double get level =>
      amplitude.value.clamp(0, AudioTestConstants.amplitudeLevelMax) /
      AudioTestConstants.amplitudeLevelMax;

  // ==================== DỌN DẸP TÀI NGUYÊN ====================

  Future<void> _disposeRecording() async {
    try {
      await _sub?.cancel();
      _sub = null;
      if (await _rec.isRecording()) {
        await _rec.stop();
      }
      await _rec.dispose();

      // Xoá tệp ghi âm tạm
      if (_recordingPath != null) {
        try {
          final file = File(_recordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
        _recordingPath = null;
      }
    } catch (_) {}
  }
}
