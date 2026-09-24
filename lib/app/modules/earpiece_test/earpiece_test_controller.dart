import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/audio_test_constants.dart';
import 'package:kdtd_ver2_1/app/data/services/wav_tone_generator.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

/// ============================================================
/// EarpieceTestController - Logic Bài Test Loa Trong
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test loa trong (phát sóng sine qua loa
/// trong, theo dõi cảm biến tiệm cận, tự động pass sau 3 giây kể từ lần
/// phát hiện "gần" đầu tiên) sống ở đây; `EarpieceTestPage` chỉ còn là UI
/// thuần đọc các field `.obs` qua `Obx`.
class EarpieceTestController extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<int>? _proximitySub;
  Timer? _autoPassTimer;

  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final isNear = false.obs;
  final hasDetectedNear = false.obs;
  final isPlaying = false.obs;
  final nearCount = 0.obs;

  /// Lỗi phát âm thanh (nếu có) — hiển thị ngay trong dialog.
  ///
  /// KHÔNG dùng `Get.snackbar` ở đây: dialog test được mở bằng `Get.dialog`,
  /// snackbar bắn ra lúc này không tìm thấy `Overlay` và làm hỏng luôn
  /// `SnackbarController` nội bộ của GetX, khiến mọi `Get.back()` sau đó ném
  /// `LateInitializationError` và dialog không bao giờ đóng được.
  final errorMessage = ''.obs;

  /// Chặn `finish()` chạy nhiều lần (bấm nút liên tục / timer trùng pop).
  bool _finished = false;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  @override
  void onClose() {
    _autoPassTimer?.cancel();
    _proximitySub?.cancel();
    _player.stop();
    _player.dispose();
    super.onClose();
  }

  Future<void> _start() async {
    try {
      // iOS mặc định dùng category `playback` — luôn phát ra LOA NGOÀI. Phải
      // chuyển sang `playAndRecord` (và KHÔNG bật defaultToSpeaker) thì âm mới
      // đi ra loa trong (receiver), đúng mục đích bài test.
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {},
          ),
        ),
      );

      // Thiết lập trình phát âm thanh (Audio Player)
      await _player.setVolume(AudioTestConstants.earpieceVolume);
      await _player.setReleaseMode(ReleaseMode.loop);

      // Phát sóng sine qua loa trong
      final tone = await WavToneGenerator.sineWaveFile(
        seconds: AudioTestConstants.earpieceToneSeconds,
        freqHz: AudioTestConstants.earpieceToneFreqHz,
        amplitude: AudioTestConstants.earpieceToneAmplitude,
      );
      await _player.play(DeviceFileSource(tone.path));

      isPlaying.value = true;

      // Lắng nghe sự kiện cảm biến tiệm cận
      _proximitySub = ProximitySensor.events.listen((distance) {
        final near = distance > 0;

        isNear.value = near;
        if (near) {
          nearCount.value++;
          if (!hasDetectedNear.value) {
            hasDetectedNear.value = true;
            _startAutoPassTimer();
          }
        }
      });
    } catch (e) {
      isPlaying.value = false;
      errorMessage.value =
          '${LocaleKeys.earpiece_test_error_title.trans()}: $e';
    }
  }

  void _startAutoPassTimer() {
    _autoPassTimer?.cancel();
    _autoPassTimer = Timer(AudioTestConstants.earpieceAutoPassDelay, () {
      if (hasDetectedNear.value) {
        finish(true);
      }
    });
  }

  /// Kết thúc bài test — dừng phát âm thanh rồi pop kết quả về màn hình trước.
  Future<void> finish(bool passed) async {
    if (_finished) return;
    _finished = true;

    _autoPassTimer?.cancel();
    await _proximitySub?.cancel();
    _proximitySub = null;
    isPlaying.value = false;
    await _player.stop();

    if (Get.isDialogOpen ?? false) Get.back(result: passed);
  }
}
