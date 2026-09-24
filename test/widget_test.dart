// Basic smoke test: app khởi động không crash và hiện được màn hình đầu tiên
// (Diagnostics Home). Bài test đếm số mặc định từ `flutter create` đã bị xoá
// vì app này không phải app đếm số.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/app/my_app.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

void main() {
  // `MyApp` đọc `context.localizationDelegates` nên BẮT BUỘC phải nằm dưới
  // một `EasyLocalization`, y như trong `main.dart`. Pump `MyApp` trần sẽ ném
  // "Null check operator used on a null value".
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // easy_localization lưu locale đã chọn vào SharedPreferences; trong môi
    // trường test không có plugin nền tảng nên phải mock, nếu không
    // `ensureInitialized()` ném MissingPluginException.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('App mở ra màn Welcome rồi vào được Kiểm Định Thiết Bị',
      (tester) async {
    // Khung test mặc định là 800x600 (ngang, cỡ tablet) trong khi app thiết kế
    // cho điện thoại dọc (ScreenUtil designSize 375x812) — để nguyên thì layout
    // tràn và bài test fail vì lý do không liên quan tới thứ đang kiểm tra.
    tester.view.physicalSize = const Size(1125, 2436); // iPhone 11 Pro @3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        startLocale: const Locale('vi'),
        child: const MyApp(),
      ),
    );

    // Chờ nạp xong file dịch + dựng route đầu tiên.
    await tester.pumpAndSettle();

    // Đọc thẳng từ file dịch thay vì hard-code chuỗi: assertion cũ tìm
    // "Thu Cũ Đổi Mới" (key `appbar_title`) trong khi màn hình đã đổi sang
    // dùng `header_title` từ lâu, nên bài test fail mà không ai để ý.

    // 1. Màn mở đầu là Welcome.
    expect(find.text(LocaleKeys.welcome_title.trans()), findsOneWidget);

    // 2. Bấm "Bắt đầu kiểm định" thì sang được trang chủ kiểm định —
    // bắt luôn lỗi thiếu binding/route, thứ mà chỉ dựng widget không lộ ra.
    await tester.tap(find.text(LocaleKeys.welcome_start_btn.trans()));
    await tester.pumpAndSettle();

    expect(
      find.text(LocaleKeys.diagnostics_home_header_title.trans()),
      findsOneWidget,
    );
  });
}
