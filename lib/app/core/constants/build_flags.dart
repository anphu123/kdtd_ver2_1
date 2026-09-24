/// Cờ cấu hình theo từng bản build (truyền qua `--dart-define`).
class BuildFlags {
  BuildFlags._();

  /// Hiện dải băng "THỬ NGHIỆM" ở góc màn hình.
  ///
  /// KHÔNG dùng `debugShowCheckedModeBanner` của Flutter cho việc này: dải
  /// băng DEBUG đó được gắn bên trong một `assert()`, mà `assert` bị xoá sạch
  /// khi biên dịch release — nên bản TestFlight không bao giờ hiện, đặt `true`
  /// hay `false` đều như nhau.
  ///
  /// Mặc định BẬT vì app đang trong giai đoạn thử nghiệm nội bộ. Khi phát
  /// hành thật, build kèm:
  ///
  /// ```bash
  /// flutter build ipa --dart-define=SHOW_TEST_BANNER=false
  /// ```
  ///
  /// hoặc đổi `defaultValue` ở đây thành `false`.
  static const bool showTestBanner = bool.fromEnvironment(
    'SHOW_TEST_BANNER',
    defaultValue: true,
  );
}
