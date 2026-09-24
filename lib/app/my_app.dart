import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;

import 'core/constants/build_flags.dart';
import 'core/extensions/string_extensions.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

/// Root widget của app — cấu hình theme, route table (GetX), i18n và responsive screenutil (.r, .h, .w, .sp).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: LocaleKeys.common_app_title.trans(),
          // Tắt băng DEBUG mặc định của Flutter để khỏi chồng lên băng
          // "THỬ NGHIỆM" bên dưới (cả hai đều nằm ở góc trên phải).
          debugShowCheckedModeBanner: false,
          builder: _wrapWithTestBanner,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,

          // Nhịp chuyển màn cho các lần điều hướng KHÔNG qua bảng route
          // (`Get.to`/`Get.off` truyền thẳng widget) — không đặt ở đây thì
          // chúng rơi về mặc định của GetX và lệch nhịp với các route đã
          // khai báo trong AppPages.
          defaultTransition: AppPages.forward,
          transitionDuration: AppPages.transitionDuration,
          onInit: () {
            // GetMaterialApp không có tham số cho đường cong mặc định, mà
            // mặc định của GetX là easeOutQuad — khác fastOutSlowIn dùng cho
            // các route. Gán thẳng vào root controller cho đồng bộ.
            Get.rootController.defaultTransitionCurve =
                AppPages.transitionCurve;
          },
        );
      },
    );
  }

  /// Dán dải băng "THỬ NGHIỆM" lên mọi màn hình khi đang build bản nội bộ.
  ///
  /// Dùng widget `Banner` tự đặt chứ không phải `debugShowCheckedModeBanner`,
  /// vì cái đó chỉ tồn tại ở chế độ debug — xem [BuildFlags.showTestBanner].
  static Widget _wrapWithTestBanner(BuildContext context, Widget? child) {
    final content = child ?? const SizedBox.shrink();
    if (!BuildFlags.showTestBanner) return content;

    return Banner(
      message: 'THỬ NGHIỆM',
      location: BannerLocation.topEnd,
      color: AppColors.pviRed,
      child: content,
    );
  }
}
