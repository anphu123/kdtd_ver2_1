// Basic smoke test: app khởi động không crash và hiện được màn hình đầu tiên
// (Diagnostics Home). Bài test đếm số mặc định từ `flutter create` đã bị xoá
// vì app này không phải app đếm số.

import 'package:flutter_test/flutter_test.dart';

import 'package:kdtd_ver2_1/app/my_app.dart';

void main() {
  testWidgets('App khởi động và hiện màn hình Thu Cũ Đổi Mới', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Thu Cũ Đổi Mới'), findsOneWidget);
  });
}
