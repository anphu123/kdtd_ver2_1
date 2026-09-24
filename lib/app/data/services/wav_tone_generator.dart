import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Sinh dữ liệu WAV (PCM 16-bit mono) chứa 1 tông sóng sine — dùng để phát
/// tiếng test qua loa ngoài/loa trong mà không cần file âm thanh đính kèm.
class WavToneGenerator {
  WavToneGenerator._();

  static Uint8List sineWave({
    int sampleRate = 44100,
    int seconds = 1,
    double freqHz = 880,
    double amplitude = 0.5,
  }) {
    final total = sampleRate * seconds;
    final data = ByteData(44 + total * 2);

    void w16(int o, int v) => data.setUint16(o, v, Endian.little);
    void w32(int o, int v) => data.setUint32(o, v, Endian.little);

    // Tiêu đề định dạng WAV (WAV Header)
    data.buffer.asUint8List().setRange(0, 4, 'RIFF'.codeUnits);
    w32(4, 36 + total * 2);
    data.buffer.asUint8List().setRange(8, 12, 'WAVE'.codeUnits);
    data.buffer.asUint8List().setRange(12, 16, 'fmt '.codeUnits);
    w32(16, 16);
    w16(20, 1); // Định dạng PCM
    w16(22, 1); // Kênh đơn (Mono)
    w32(24, sampleRate);
    w32(28, sampleRate * 2);
    w16(32, 2);
    w16(34, 16);
    data.buffer.asUint8List().setRange(36, 40, 'data'.codeUnits);
    w32(40, total * 2);

    // Sóng sine
    final amp = 32767 * amplitude;
    var off = 44;
    for (var n = 0; n < total; n++) {
      final s = (sin(2 * pi * freqHz * (n / sampleRate)) * amp).round();
      data.setInt16(off, s, Endian.little);
      off += 2;
    }

    return data.buffer.asUint8List();
  }

  /// Ghi dữ liệu WAV ra file tạm **có đuôi `.wav`** và trả về nguồn phát.
  ///
  /// `BytesSource` không dùng được trên iOS/macOS: audioplayers ghi bytes ra
  /// file tạm KHÔNG có phần mở rộng, AVPlayer không đoán được định dạng nên
  /// luôn báo `AVPlayerItem.Status.failed on setSourceUrl`. Tự ghi file kèm
  /// đuôi `.wav` là cách duy nhất để AVPlayer nhận diện được.
  ///
  /// File được đặt tên theo tham số nên chỉ ghi một lần rồi tái sử dụng.
  static Future<File> sineWaveFile({
    int sampleRate = 44100,
    int seconds = 1,
    double freqHz = 880,
    double amplitude = 0.5,
  }) async {
    final dir = await getTemporaryDirectory();
    final name =
        'tone_${sampleRate}_${seconds}_${freqHz.toStringAsFixed(0)}_'
        '${(amplitude * 1000).round()}.wav';
    final file = File('${dir.path}/$name');

    if (!file.existsSync()) {
      await file.writeAsBytes(
        sineWave(
          sampleRate: sampleRate,
          seconds: seconds,
          freqHz: freqHz,
          amplitude: amplitude,
        ),
        flush: true,
      );
    }

    return file;
  }
}
