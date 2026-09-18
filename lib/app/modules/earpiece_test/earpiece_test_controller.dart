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
      // Thiết lập trình phát âm thanh (Audio Player)
      await _player.setVolume(AudioTestConstants.earpieceVolume);
      await _player.setReleaseMode(ReleaseMode.loop);

      // Phát sóng sine qua loa trong
      await _player.play(
        BytesSource(
          WavToneGenerator.sineWave(
            seconds: AudioTestConstants.earpieceToneSeconds,
            freqHz: AudioTestConstants.earpieceToneFreqHz,
            amplitude: AudioTestConstants.earpieceToneAmplitude,
          ),
        ),
      );

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
      Get.snackbar(
        LocaleKeys.earpiece_test_error_title.trans(),
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    await _player.stop();
    Get.back(result: passed);
  }
}
