import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
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

  // ==================== REACTIVE STATE ====================
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

  // ==================== LIFECYCLE (app pause/resume) ====================

  /// Ứng dụng bị đưa xuống nền — dừng thu âm để tránh giữ tài nguyên.
  Future<void> onAppPaused() async {
    await _disposeRecording();
    ready.value = false;
  }

  /// Ứng dụng quay lại foreground — khởi động lại bài test từ đầu.
  void onAppResumed() {
    start();
  }

  // ==================== SETUP ====================

  /// Khởi động (hoặc khởi động lại) toàn bộ bài test micro.
  Future<void> start() async {
    phase.value = MicTestPhase.recording;
    amplitude.value = 0.0;
    maxAmplitude.value = 0.0;
    ready.value = false;
    hasDetectedSound.value = false;
    error.value = null;
    amplitudeHistory.clear();
    countdown.value = 5;

    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        error.value = 'Ứng dụng không có quyền Micro.';
        return;
      }

      final ok = await _rec.hasPermission();
      if (!ok) {
        error.value = 'Thiết bị không cấp quyền ghi âm.';
        return;
      }

      if (await _rec.isRecording()) {
        await _rec.stop();
      }

      // Create temp file path for recording
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/mic_test_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording for amplitude monitoring
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordingPath!,
      );

      await _sub?.cancel();
      _sub = _rec
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen(
            (a) {
              final currentAmp = a.current.abs();

              // Lưu lịch sử amplitude cho waveform
              amplitudeHistory.add(currentAmp);
              if (amplitudeHistory.length > 50) {
                amplitudeHistory.removeAt(0);
              }

              amplitude.value = currentAmp;
              if (currentAmp > maxAmplitude.value) {
                maxAmplitude.value = currentAmp;
              }
              // Phát hiện âm thanh (threshold: 1000)
              if (currentAmp > 1000) {
                hasDetectedSound.value = true;
              }
            },
            onError: (e) {
              error.value = 'Lỗi amplitude: $e';
            },
          );

      ready.value = true;

      // Bắt đầu countdown 5 giây
      _startRecordingCountdown();
    } catch (e) {
      error.value = 'Không thể khởi động micro: $e';
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
      error.value = 'Lỗi khi phát lại: $e';
      phase.value = MicTestPhase.confirming;
    }
  }

  /// Kết thúc bài test — pop kết quả về màn hình trước.
  void finish(bool passed) => Get.back(result: passed);

  // ==================== CLEANUP ====================

  Future<void> _disposeRecording() async {
    try {
      await _sub?.cancel();
      _sub = null;
      if (await _rec.isRecording()) {
        await _rec.stop();
      }
      await _rec.dispose();

      // Delete temp recording file
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
