import 'package:flutter/foundation.dart';

/// DiagLogger - Centralized logging for diagnostics
/// Giảm log spam, chỉ hiển thị khi debug mode bật
class DiagLogger {
  static bool _debugMode = false;
  static bool _verboseMode = false;

  /// Bật debug mode
  static void enableDebug() => _debugMode = true;

  /// Tắt debug mode
  static void disableDebug() => _debugMode = false;

  /// Bật verbose mode (hiển thị tất cả)
  static void enableVerbose() {
    _debugMode = true;
    _verboseMode = true;
  }

  /// Log thông thường (chỉ khi debug mode)
  static void log(String message) {
    if (_debugMode) {
      debugPrint('[DIAG] $message');
    }
  }

  /// Log info cho một bước test
  static void info(String code, String message) {
    if (_debugMode) {
      debugPrint('[DIAG][$code] ℹ️ $message');
    }
  }

  /// Log success - luôn hiển thị
  static void success(String code, String message) {
    debugPrint('[DIAG][$code] ✅ $message');
  }

  /// Log error - luôn hiển thị
  static void error(String code, String message) {
    debugPrint('[DIAG][$code] ❌ $message');
  }

  /// Log skip (chỉ khi debug)
  static void skip(String code, String reason) {
    if (_debugMode) {
      debugPrint('[DIAG][$code] ⊝ SKIP: $reason');
    }
  }

  /// Log warning - luôn hiển thị
  static void warning(String code, String message) {
    debugPrint('[DIAG][$code] ⚠️ $message');
  }

  /// Log verbose (chỉ khi verbose mode)
  static void verbose(String message) {
    if (_verboseMode) {
      debugPrint('[DIAG][VERBOSE] $message');
    }
  }

  /// Log phase header
  static void phaseStart(String phaseName, int stepCount) {
    if (_debugMode) {
      debugPrint('\n━━━ PHASE: $phaseName ($stepCount tests) ━━━');
    }
  }

  /// Log phase complete
  static void phaseComplete(
    String phaseName,
    int passed,
    int failed,
    int skipped,
  ) {
    if (_debugMode) {
      debugPrint('━━━ $phaseName DONE: ✅$passed ❌$failed ⊝$skipped ━━━\n');
    }
  }

  /// Log timing
  static void timing(String operation, Duration duration) {
    if (_debugMode) {
      debugPrint('[DIAG][TIME] $operation: ${duration.inMilliseconds}ms');
    }
  }

  /// Log summary kết quả cuối cùng (luôn hiển thị)
  static void summary({
    required int total,
    required int passed,
    required int failed,
    required int skipped,
    required int score,
    required String grade,
    required Duration totalDuration,
  }) {
    debugPrint('\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║               KẾT QUẢ KIỂM ĐỊNH                            ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('${'║  Tổng số test:  $total'.padRight(60)}║');
    debugPrint('${'║  ✅ Passed:     $passed'.padRight(60)}║');
    debugPrint('${'║  ❌ Failed:     $failed'.padRight(60)}║');
    debugPrint('${'║  ⊝ Skipped:    $skipped'.padRight(60)}║');
    debugPrint('${'║  📈 Điểm số:    $score/100'.padRight(60)}║');
    debugPrint('${'║  🏆 Xếp loại:   $grade'.padRight(60)}║');
    debugPrint('${'║  ⏱️ Thời gian:   ${totalDuration.inSeconds}s'.padRight(60)}║');
    debugPrint('╚════════════════════════════════════════════════════════════╝\n');
  }
}
