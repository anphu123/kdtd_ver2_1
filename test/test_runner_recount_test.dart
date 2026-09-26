import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `restartStep` gọi `_updateEnvironment`, hàm này đọc trạng thái quyền qua
  // permission_handler. Môi trường test không có plugin nền tảng nên giả lập
  // kênh: mọi quyền đều đã cấp (1 = PermissionStatus.granted).
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => 1,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });

  // Tái hiện lỗi thật: Wi-Fi lần đầu LỖI, kỹ thuật viên bấm thử lại thì ĐẠT,
  // nhưng máy vẫn bị chấm Loại 5. Nguyên nhân là bộ đếm được cộng dồn bằng
  // `++` — thử lại chỉ tăng passedCount, failedCount vẫn giữ kết quả cũ, mà
  // bất kỳ failedCount > 0 nào cũng kéo máy xuống Loại 5.
  test('thử lại một bước từ LỖI sang ĐẠT thì không còn bị tính là lỗi', () async {
    var wifiWorks = false;
    final runner = TestRunnerController();
    final wifi = DiagStep(
      code: 'wifi',
      title: 'Wi-Fi',
      kind: DiagKind.auto,
      run: () async => wifiWorks,
    );
    runner.steps.assignAll([wifi]);

    // Lần 1: Wi-Fi lỗi.
    await runner.restartStep(wifi);
    expect(wifi.status, DiagStatus.failed);
    expect(runner.failedCount.value, 1);

    // Thử lại: Wi-Fi đạt.
    wifiWorks = true;
    await runner.restartStep(wifi);

    expect(wifi.status, DiagStatus.passed);
    expect(
      runner.failedCount.value,
      0,
      reason: 'lỗi cũ phải bị xoá, không thì máy bị chấm oan Loại 5',
    );
    expect(runner.passedCount.value, 1);
    expect(
      runner.completed,
      runner.total,
      reason: '"đã xong" không được vượt quá tổng số bước',
    );
  });

  test('thử lại theo chiều ngược lại (ĐẠT sang LỖI) cũng đếm đúng', () async {
    var works = true;
    final runner = TestRunnerController();
    final step = DiagStep(
      code: 'wifi',
      title: 'Wi-Fi',
      kind: DiagKind.auto,
      run: () async => works,
    );
    runner.steps.assignAll([step]);

    await runner.restartStep(step);
    expect(runner.passedCount.value, 1);

    works = false;
    await runner.restartStep(step);

    expect(runner.passedCount.value, 0);
    expect(runner.failedCount.value, 1);
  });
}
