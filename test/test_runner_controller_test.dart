import 'dart:async';

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
  test(
    'thử lại một bước từ LỖI sang ĐẠT thì không còn bị tính là lỗi',
    () async {
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
    },
  );

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

  // Tái hiện lỗi thật: bấm back thoát khỏi màn Test Runner giữa chừng, vòng
  // lặp vẫn chạy tiếp và bật dialog loa, micro, camera đè lên màn khác —
  // vì controller đăng ký `permanent: true` nên rời màn không làm nó chết.
  test('rời màn giữa chừng thì các bước sau KHÔNG chạy nữa', () async {
    final runner = TestRunnerController();
    final ran = <String>[];
    // Giữ bước đầu treo ở giữa chừng, như một bài test đang chạy dở.
    final firstStepGate = Completer<bool>();

    final wifi = DiagStep(
      code: 'wifi',
      title: 'Wi-Fi',
      kind: DiagKind.auto,
      phase: DiagPhase.connectivity,
      run: () {
        ran.add('wifi');
        return firstStepGate.future;
      },
    );
    final speaker = DiagStep(
      code: 'external-speaker',
      title: 'Loa ngoài',
      kind: DiagKind.auto,
      phase: DiagPhase.hardware,
      run: () async {
        ran.add('external-speaker');
        return true;
      },
    );
    runner.steps.assignAll([wifi, speaker]);

    final run = runner.startFunctionalDiagnostics();

    // Đợi tới lúc bước đầu thật sự đang chạy.
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!ran.contains('wifi')) {
      if (DateTime.now().isAfter(deadline)) fail('bước wifi không bắt đầu');
      await Future.delayed(const Duration(milliseconds: 10));
    }
    expect(wifi.status, DiagStatus.running);

    // Người dùng thoát màn, rồi bước đang dở mới chạy xong.
    runner.cancelRun();
    firstStepGate.complete(true);
    await run;

    expect(ran, [
      'wifi',
    ], reason: 'bước kế tiếp không được chạy sau khi đã huỷ');
    expect(
      wifi.status,
      DiagStatus.pending,
      reason: 'bước dở dang không được ghi kết quả — lần sau chạy lại',
    );
    expect(runner.isRunning.value, isFalse);
  });

  test('cancelRun() khi không có lượt nào đang chạy thì không làm gì', () {
    final runner = TestRunnerController();
    final done = DiagStep(
      code: 'wifi',
      title: 'Wi-Fi',
      kind: DiagKind.auto,
      status: DiagStatus.passed,
    );
    runner.steps.assignAll([done]);

    // Test Runner xong thì điều hướng đi, màn dispose và gọi cancelRun() —
    // lúc đó không được đụng vào kết quả đã có.
    runner.cancelRun();

    expect(done.status, DiagStatus.passed);
  });

  // Wi-Fi, Bluetooth, Vị trí từng hết giờ và bị chấm FAIL ngay lúc người
  // dùng đang bấm "Cho phép" hoặc đang mở Cài đặt theo hướng dẫn của app:
  // phần chờ người nằm CHUNG trong thời hạn đo việc của máy.
  //
  // Hai test dưới cùng một khoảng chờ 600ms, thời hạn 300ms. Chỉ khác chỗ
  // đặt khoảng chờ — và đó chính là toàn bộ bản sửa.
  group('thời gian chờ người không tính vào thời hạn của bước', () {
    const humanWait = Duration(milliseconds: 600);
    const machineBudget = Duration(milliseconds: 300);

    test('chờ người trong prepare -> bước vẫn ĐẠT', () async {
      final runner = TestRunnerController();
      final step = DiagStep(
        code: 'wifi',
        title: 'Wi-Fi',
        kind: DiagKind.auto,
        timeout: machineBudget,
        // Người dùng mất 600ms để bấm "Cho phép".
        prepare: () => Future.delayed(humanWait),
        run: () async => true,
      );
      runner.steps.assignAll([step]);

      await runner.restartStep(step);

      expect(
        step.status,
        DiagStatus.passed,
        reason: 'thời gian người bấm không được tính vào thời hạn của máy',
      );
    });

    test(
      'chờ cùng khoảng đó trong run -> bước HẾT GIỜ (thời hạn vẫn có hiệu lực)',
      () async {
        final runner = TestRunnerController();
        final step = DiagStep(
          code: 'wifi',
          title: 'Wi-Fi',
          kind: DiagKind.auto,
          timeout: machineBudget,
          // Đây chính là cách code cũ làm: hỏi quyền nằm bên trong run.
          run: () => Future.delayed(humanWait, () => true),
        );
        runner.steps.assignAll([step]);

        await runner.restartStep(step);

        expect(step.status, DiagStatus.failed);
      },
    );
  });
}
