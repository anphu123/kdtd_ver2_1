import 'dart:async';
import 'dart:io';

import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/audio_test_constants.dart';
import 'package:kdtd_ver2_1/app/data/services/permission_gate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// ============================================================
/// MicTestController - Logic Bài Test Micro
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test micro (xin quyền, thu âm 5 giây với
/// theo dõi biên độ, xử lý vòng đời ứng dụng) sống ở đây; trang
/// (`MicTestPage`) chỉ còn là UI thuần đọc các field `.obs` qua `Obx`.
///
/// Kết quả pass/fail được chấm TỰ ĐỘNG theo biên độ (dBm) đo được trong lúc
/// ghi âm — không còn phát lại cho người dùng tự nghe rồi bấm "rõ/không rõ",
/// vì cách đó chủ quan và không phản ánh đúng chất lượng phần cứng mic.
class MicTestController extends GetxController {
  final AudioRecorder _rec = AudioRecorder();
  StreamSubscription<Amplitude>? _sub;
  String? _recordingPath;
  Timer? _countdownTimer;

  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final amplitude = AudioTestConstants.amplitudeDbfsFloor.obs;
  final maxAmplitude = AudioTestConstants.amplitudeDbfsFloor.obs;
  final ready = false.obs;
  final hasDetectedSound = false.obs;
  final error = Rx<String?>(null);
  final amplitudeHistory = <double>[].obs;
  final countdown = 5.obs;

  /// Chặn `finish()` chạy nhiều lần (countdown trùng với thao tác thủ công).
  bool _finished = false;

  @override
  void onInit() {
    super.onInit();
    start();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
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
    amplitude.value = AudioTestConstants.amplitudeDbfsFloor;
    maxAmplitude.value = AudioTestConstants.amplitudeDbfsFloor;
    ready.value = false;
    hasDetectedSound.value = false;
    error.value = null;
    amplitudeHistory.clear();
    countdown.value = AudioTestConstants.micRecordingSeconds;

    try {
      final micGranted = await PermissionGate.ensure(
        Permission.microphone,
        name: LocaleKeys.permission_microphone_name.trans(),
      );
      if (!micGranted) {
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
      try {
        await _rec.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: AudioTestConstants.recordingBitRate,
            sampleRate: AudioTestConstants.recordingSampleRate,
            numChannels: AudioTestConstants.recordingChannels,
            androidConfig: AndroidRecordConfig(
              audioSource: AndroidAudioSource.unprocessed,
            ),
          ),
          path: _recordingPath!,
        );
      } catch (e) {
        // Fallback về mặc định nếu không hỗ trợ unprocessed
        await _rec.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: AudioTestConstants.recordingBitRate,
            sampleRate: AudioTestConstants.recordingSampleRate,
            numChannels: AudioTestConstants.recordingChannels,
          ),
          path: _recordingPath!,
        );
      }

      await _sub?.cancel();
      _sub = _rec
          .onAmplitudeChanged(AudioTestConstants.amplitudeSampleInterval)
          .listen(
            (a) {
              final currentAmp = a.current;

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
              // Phát hiện âm thanh — đây là căn cứ DUY NHẤT để chấm pass/fail.
              if (currentAmp > AudioTestConstants.soundDetectionDbfsThreshold) {
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
        _finishRecordingAndEvaluate();
      }
    });
  }

  /// Dừng ghi âm và tự động chấm pass/fail theo biên độ đã đo được — không
  /// cần phát lại, không cần người dùng xác nhận thủ công.
  Future<void> _finishRecordingAndEvaluate() async {
    try {
      await _sub?.cancel();
      _sub = null;

      if (await _rec.isRecording()) {
        await _rec.stop();
      }
    } catch (_) {}

    finish(hasDetectedSound.value);
  }

  /// Kết thúc bài test — pop kết quả về màn hình trước.
  void finish(bool passed) {
    if (_finished) return;
    _finished = true;

    _countdownTimer?.cancel();
    if (Get.isDialogOpen ?? false) Get.back(result: passed);
  }

  /// Mức âm lượng đã chuẩn hoá (0.0 - 1.0) để hiển thị animation.
  double get level =>
      ((amplitude.value - AudioTestConstants.amplitudeDbfsFloor) /
              (0 - AudioTestConstants.amplitudeDbfsFloor))
          .clamp(0.0, 1.0);

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
