import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension hỗ trợ dịch chuỗi bằng cú pháp `.trans()`
/// Cho phép viết: `LocaleKeys.login.trans()` tương đương với `.tr()`
extension StringTransExtension on String {
  String trans({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) {
    return tr(
      this,
      args: args,
      namedArgs: namedArgs,
      gender: gender,
      context: context,
    );
  }
}
