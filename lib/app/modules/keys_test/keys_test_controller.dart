import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ============================================================
/// KeysTestController - Logic Bài Test Phím Vật Lý
/// ============================================================
///
/// Toàn bộ nghiệp vụ của bài test phím vật lý (Volume Up/Down, Back,
/// Power thủ công) sống ở đây — tách khỏi `KeysTestPage`, vốn chỉ còn là
/// UI thuần đọc các field `.obs` này và gọi lại các method. Controller
/// lắng nghe `EventChannel('com.fidobox/diagnostics_keyevents')` cho
/// luồng chính (đếm ngược 5s mặc định) và cung cấp [waitForKey] — một
/// hàm chờ 1 lần cho luồng "Chạy tự động" — không đụng tới
/// BuildContext/Navigator/showDialog, những phần đó là việc của Page.
class KeysTestController extends GetxController {
  static const _keyEventChannel = EventChannel('com.fidobox/diagnostics_keyevents');

  final volUp = false.obs;
  final volDown = false.obs;
  final backPressed = false.obs;
  final powerConfirmed = false.obs;

  final volUpFailed = false.obs;
  final volDownFailed = false.obs;

  final remainingSeconds = 0.obs;

  StreamSubscription<Map<dynamic, dynamic>>? _keySub;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();

    // Lắng nghe sự kiện phím từ native (EventChannel) cho luồng chính.
    try {
      _keySub = _keyEventChannel
          .receiveBroadcastStream()
          .map<Map<dynamic, dynamic>>((event) => (event as Map).cast<dynamic, dynamic>())
          .listen((m) {
        try {
          final keyCode = m['keyCode'] as int?;
          final action = m['action'] as String?;
          if (action == 'down') {
            if (keyCode == 24) {
              markVolUp();
            } else if (keyCode == 25) {
              markVolDown();
            } else if (keyCode == 4) {
              markBackPressed();
            }
          }
        } catch (_) {
          // ignore malformed events
        }
      }, onError: (_) {
        // ignore
      });
    } on MissingPluginException {
      // Native EventChannel chưa sẵn sàng — luồng chính vẫn hoạt động
      // qua FocusNode/onKeyEvent (do Page xử lý) và đánh dấu thủ công.
    }

    // Mặc định chạy đếm ngược 5s cho bài test volume.
    startVolumeCountdown(seconds: 5);
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    try {
      _keySub?.cancel();
    } catch (_) {
      // Ignore cancellation errors
    }
    super.onClose();
  }

  void markVolUp() {
    if (!volUp.value) {
      volUp.value = true;
      volUpFailed.value = false;
    }
    _cancelCountdownIfBothDone();
  }

  void markVolDown() {
    if (!volDown.value) {
      volDown.value = true;
      volDownFailed.value = false;
    }
    _cancelCountdownIfBothDone();
  }

  void markVolUpFailed() => volUpFailed.value = true;

  void markVolDownFailed() => volDownFailed.value = true;

  void markBackPressed() {
    if (!backPressed.value) backPressed.value = true;
  }

  void setPowerConfirmed(bool value) => powerConfirmed.value = value;

  void _cancelCountdownIfBothDone() {
    if (volUp.value && volDown.value) _cancelCountdown();
  }

  /// Bắt đầu (lại) đếm ngược `seconds` giây cho bài test volume mặc định.
  void startVolumeCountdown({int seconds = 5}) {
    _cancelCountdown();
    volUp.value = false;
    volDown.value = false;
    volUpFailed.value = false;
    volDownFailed.value = false;
    remainingSeconds.value = seconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remainingSeconds.value -= 1;
      if (remainingSeconds.value <= 0) {
        if (!volUp.value) volUpFailed.value = true;
        if (!volDown.value) volDownFailed.value = true;
        _cancelCountdown();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    remainingSeconds.value = 0;
  }

  /// Chờ đúng 1 lần cho tới khi nhận được [expectedKeyCode] hoặc hết
  /// [seconds] giây — dùng cho luồng "Chạy tự động" (Page hiển thị dialog
  /// với đếm ngược riêng trong lúc chờ). Quản lý subscription tạm thời
  /// của riêng nó; không có UI/BuildContext/Navigator/showDialog nào ở
  /// đây. Ném lại [MissingPluginException] nếu EventChannel chưa được
  /// đăng ký để Page tự quyết định hiển thị thông báo phù hợp.
  Future<bool> waitForKey(int expectedKeyCode, {int seconds = 5}) async {
    final completer = Completer<bool>();
    StreamSubscription<Map<dynamic, dynamic>>? sub;
    Timer? timer;
    var isDone = false;

    void complete(bool value) {
      if (isDone) return;
      isDone = true;
      timer?.cancel();
      try {
        sub?.cancel();
      } catch (_) {
        // Ignore "No active stream" errors
      }
      completer.complete(value);
    }

    sub = _keyEventChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((event) => (event as Map).cast<dynamic, dynamic>())
        .listen((m) {
      try {
        final keyCode = m['keyCode'] as int?;
        final action = m['action'] as String?;
        if (action == 'down' && keyCode == expectedKeyCode) {
          complete(true);
        }
      } catch (_) {
        // ignore malformed events
      }
    }, onError: (_) {
      // ignore
    });

    timer = Timer(Duration(seconds: seconds), () => complete(false));

    return completer.future;
  }

  Map<String, dynamic> _buildResult() {
    final passed = volUp.value && volDown.value;
    return {
      'userConfirm': passed, // pass khi 2 phím volume OK
      'volumeUp': volUp.value,
      'volumeDown': volDown.value,
      'back': backPressed.value,
      'powerManualConfirm': powerConfirmed.value, // tick thủ công phím nguồn
    };
  }

  /// Kết thúc bài test — pop kết quả ngay qua `Get.back`.
  void finish() => Get.back(result: _buildResult());
}
