import 'package:flutter_test/flutter_test.dart';
import 'package:kdtd_ver2_1/app/core/constants/diagnostics_constants.dart';

void main() {
  // Bài Bluetooth làm tuần tự: chờ adapter báo trạng thái thật, rồi quét.
  // Tổng hai khâu đó PHẢI nằm gọn trong thời hạn của cả bài, nếu không bài
  // hết giờ và bị chấm FAIL dù Bluetooth đang bật và đã cấp quyền.
  //
  // Lỗi này từng xảy ra thật: hạn chờ adapter bị nâng từ 500ms lên 4s trong
  // khi thời hạn cả bài vẫn là 5s cứng — 4s + 2s quét = 6s > 5s.
  test('ngân sách thời gian bài Bluetooth không vượt thời hạn của bài', () {
    const adapter = DiagnosticsConstants.bluetoothAdapterStateTimeout;
    const scan = DiagnosticsConstants.bluetoothScanDuration;
    const step = DiagnosticsConstants.bluetoothStepTimeout;

    // Chừa ít nhất 2 giây cho phần việc còn lại: đọc quyền, dừng quét, và
    // độ trễ kênh native trên máy chậm.
    const margin = Duration(seconds: 2);

    expect(
      adapter + scan + margin <= step,
      isTrue,
      reason:
          'chờ adapter (${adapter.inMilliseconds}ms) + quét '
          '(${scan.inMilliseconds}ms) + dự phòng (${margin.inMilliseconds}ms) '
          'phải <= thời hạn bài (${step.inMilliseconds}ms)',
    );
  });

  test('chu kỳ thăm dò adapter đủ dày so với hạn chờ', () {
    // Thăm dò thưa quá thì phát hiện trạng thái trễ, ăn vào ngân sách.
    expect(
      DiagnosticsConstants.bluetoothAdapterPollInterval * 10 <=
          DiagnosticsConstants.bluetoothAdapterStateTimeout,
      isTrue,
    );
  });
}
