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
      print('[DIAG] $message');
    }
  }

  /// Log info cho một bước test
  static void info(String code, String message) {
    if (_debugMode) {
      print('[DIAG][$code] ℹ️ $message');
    }
  }

  /// Log success - luôn hiển thị
  static void success(String code, String message) {
    print('[DIAG][$code] ✅ $message');
  }

  /// Log error - luôn hiển thị
  static void error(String code, String message) {
    print('[DIAG][$code] ❌ $message');
  }

  /// Log skip (chỉ khi debug)
  static void skip(String code, String reason) {
    if (_debugMode) {
      print('[DIAG][$code] ⊝ SKIP: $reason');
    }
  }

  /// Log warning - luôn hiển thị
  static void warning(String code, String message) {
    print('[DIAG][$code] ⚠️ $message');
  }

  /// Log verbose (chỉ khi verbose mode)
  static void verbose(String message) {
    if (_verboseMode) {
      print('[DIAG][VERBOSE] $message');
    }
  }

  /// Log phase header
  static void phaseStart(String phaseName, int stepCount) {
    if (_debugMode) {
      print('\n━━━ PHASE: $phaseName ($stepCount tests) ━━━');
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
      print('━━━ $phaseName DONE: ✅$passed ❌$failed ⊝$skipped ━━━\n');
    }
  }

  /// Log timing
  static void timing(String operation, Duration duration) {
    if (_debugMode) {
      print('[DIAG][TIME] $operation: ${duration.inMilliseconds}ms');
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
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║               KẾT QUẢ KIỂM ĐỊNH                            ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('║  Tổng số test:  $total'.padRight(60) + '║');
    print('║  ✅ Passed:     $passed'.padRight(60) + '║');
    print('║  ❌ Failed:     $failed'.padRight(60) + '║');
    print('║  ⊝ Skipped:    $skipped'.padRight(60) + '║');
    print('║  📈 Điểm số:    $score/100'.padRight(60) + '║');
    print('║  🏆 Xếp loại:   $grade'.padRight(60) + '║');
    print('║  ⏱️ Thời gian:   ${totalDuration.inSeconds}s'.padRight(60) + '║');
    print('╚════════════════════════════════════════════════════════════╝\n');
  }
}
