/// Hằng số dùng chung cho các bài test âm thanh (Mic, Loa trong, Loa ngoài).
class AudioTestConstants {
  AudioTestConstants._();

  // ==================== KIỂM TRA MICROPHONE ====================
  /// Số giây thu âm trước khi tự động phát lại.
  static const int micRecordingSeconds = 5;

  /// Ngưỡng biên độ coi là "đã phát hiện âm thanh".
  static const double soundDetectionAmplitudeThreshold = 1000;

  /// Biên độ tối đa dùng để chuẩn hoá mức hiển thị (0.0 - 1.0) trên UI.
  static const double amplitudeLevelMax = 20000;

  /// Chu kỳ lấy mẫu biên độ micro.
  static const Duration amplitudeSampleInterval = Duration(milliseconds: 100);

  /// Số mẫu biên độ tối đa lưu lại để vẽ waveform.
  static const int amplitudeHistoryMaxLength = 50;

  /// Bitrate khi ghi âm test micro.
  static const int recordingBitRate = 128000;

  /// Sample rate khi ghi âm test micro.
  static const int recordingSampleRate = 44100;

  /// Số kênh âm thanh khi ghi âm test micro.
  static const int recordingChannels = 1;

  // ==================== KIỂM TRA LOA TRONG ====================
  /// Âm lượng phát qua loa trong.
  static const double earpieceVolume = 0.5;

  /// Độ dài 1 chu kỳ sóng sine phát lặp qua loa trong (giây).
  static const int earpieceToneSeconds = 2;

  /// Tần số sóng sine phát qua loa trong (Hz).
  static const double earpieceToneFreqHz = 800;

  /// Biên độ sóng sine phát qua loa trong.
  static const double earpieceToneAmplitude = 0.3;

  /// Thời gian giữ trạng thái "gần" liên tục trước khi tự động pass.
  static const Duration earpieceAutoPassDelay = Duration(seconds: 3);

  // ==================== KIỂM TRA LOA NGOÀI ====================
  /// Độ dài 1 chu kỳ tiếng beep phát lặp qua loa ngoài (giây).
  static const int speakerToneSeconds = 1;

  /// Tần số tiếng beep phát qua loa ngoài (Hz).
  static const double speakerToneFreqHz = 880;
}
