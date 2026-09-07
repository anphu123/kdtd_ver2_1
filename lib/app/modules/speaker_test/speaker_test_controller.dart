import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/data/services/wav_tone_generator.dart';

/// ============================================================
/// SpeakerTestController - Logic Bài Test Loa Ngoài
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test loa ngoài (phát tiếng beep dạng sóng
/// sine lặp lại) sống ở đây; `SpeakerTestPage` chỉ còn là UI thuần đọc
/// các field `.obs` qua `Obx`.
class SpeakerTestController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  // ==================== REACTIVE STATE ====================
  final playing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _playBeepLoop();
  }

  @override
  void onClose() {
    _player.stop();
    _player.dispose();
    super.onClose();
  }

  Future<void> _playBeepLoop() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(BytesSource(WavToneGenerator.sineWave(seconds: 1, freqHz: 880)));
    playing.value = true;
  }

  /// Kết thúc bài test — pop kết quả về màn hình trước.
  void finish(bool passed) => Get.back(result: passed);
}
