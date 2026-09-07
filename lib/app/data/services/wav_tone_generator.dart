import 'dart:math';
import 'dart:typed_data';

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

    // WAV header
    data.buffer.asUint8List().setRange(0, 4, 'RIFF'.codeUnits);
    w32(4, 36 + total * 2);
    data.buffer.asUint8List().setRange(8, 12, 'WAVE'.codeUnits);
    data.buffer.asUint8List().setRange(12, 16, 'fmt '.codeUnits);
    w32(16, 16);
    w16(20, 1); // PCM
    w16(22, 1); // Mono
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
}
