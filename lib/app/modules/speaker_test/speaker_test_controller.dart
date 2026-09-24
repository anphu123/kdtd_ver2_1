import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/constants/audio_test_constants.dart';
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

  // ==================== TRẠNG THÁI PHẢN ỨNG ====================
  final playing = false.obs;

  /// Chặn `finish()` chạy nhiều lần (người dùng bấm nút liên tục).
  bool _finished = false;

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

    // Dùng file `.wav` thay cho `BytesSource`: trên iOS/macOS audioplayers ghi
    // bytes ra file tạm không có phần mở rộng nên AVPlayer không nhận diện
    // được định dạng và luôn báo `AVPlayerItem.Status.failed`.
    final tone = await WavToneGenerator.sineWaveFile(
      seconds: AudioTestConstants.speakerToneSeconds,
      freqHz: AudioTestConstants.speakerToneFreqHz,
    );
    await _player.play(DeviceFileSource(tone.path));
    playing.value = true;
  }

  /// Kết thúc bài test — pop kết quả về màn hình trước.
  void finish(bool passed) {
    if (_finished) return;
    _finished = true;

    playing.value = false;
    _player.stop();
    if (Get.isDialogOpen ?? false) Get.back(result: passed);
  }
}
