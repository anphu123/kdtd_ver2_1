// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// AppColors - Hệ thống mã màu chuẩn hóa (Design System) của dự án
/// Thiết kế 100% màu thuần (Pure Solid Colors - Không Shadow, Không Alpha)
/// Định danh theo chuẩn nhận diện thương hiệu PVI INSURANCE:
/// - PVI Corporate Navy (#173665): Màu nền thanh điều hướng, tiêu đề chính, thẻ thương hiệu
/// - PVI Star Red (#E21F26): Màu ngôi sao PVI, nút CTA hành động chính, cảnh báo, điểm nhấn
/// - PVI Accent Blue (#0055A5): Màu icon kết nối mạng, bluetooth, cảm biến
/// - PVI Pure White (#FFFFFF): Màu nền thẻ card, văn bản tương phản trên nền tối
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PVI BRAND IDENTITY TOKENS (Màu thương hiệu chuẩn)
  // ===========================================================================

  /// PVI Star Red (#E21F26) - Màu đỏ ngôi sao & thông báo PVI (CTA & Alert Accent)
  static const Color pviRed = Color(0xFFE21F26);
  static const Color pviRedDark = Color(0xFFB7141A);
  static const Color pviRedLight = Color(0xFFEA4B50);
  static const Color pviRedSurface = Color(0xFFFDF2F2); // Pure solid light red background
  static const Color pviRedBorder = Color(0xFFFFD0D3); // Pure solid light red border
  static const Color pviRedLighter = pviRedSurface;

  /// PVI Corporate Navy (#173665) - Màu xanh navy đậm nhận diện PVI (Banner, Appbar, Headers)
  static const Color pviNavy = Color(0xFF173665);
  static const Color pviNavyDark = Color(0xFF0E2240);
  static const Color pviNavyLight = Color(0xFF234B85);
  static const Color pviNavySurface = Color(0xFFF0F4F8); // Pure solid light navy background
  static const Color pviNavyBorder = Color(0xFFCFDBE8); // Pure solid navy border
  static const Color pviNavyLighter = pviNavySurface;

  /// PVI Accent Blue (#0055A5) - Màu xanh dương kết nối, tính năng kỹ thuật
  static const Color pviBlue = Color(0xFF0055A5);
  static const Color pviBlueLight = Color(0xFF2E7FD1);
  static const Color pviBlueSurface = Color(0xFFEBF3FB); // Pure solid light blue background
  static const Color pviBlueBorder = Color(0xFFCCE0F5); // Pure solid blue border
  static const Color pviBlueLighter = pviBlueSurface;

  // ===========================================================================
  // 2. SEMANTIC FUNCTIONAL TOKENS (Trạng thái chức năng)
  // ===========================================================================

  /// Tác vụ chính & Tiêu đề thanh điều hướng
  static const Color primary = pviNavy;
  static const Color primaryDark = pviNavyDark;
  static const Color primaryLight = pviNavyLight;
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Tác vụ phụ & Nút kêu gọi hành động (CTA)
  static const Color secondary = pviRed;
  static const Color secondaryDark = pviRedDark;
  static const Color secondaryLight = pviRedLight;
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Success / Pass (Đạt kiểm định)
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFD1FAE5); // Solid light green
  static const Color successBorder = Color(0xFFA7F3D0); // Solid green border
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Warning / Pending (Cảnh báo, kiểm tra lại)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7); // Solid light amber
  static const Color warningBorder = Color(0xFFFDE68A); // Solid amber border
  static const Color onWarning = Color(0xFFFFFFFF);

  /// Error / Fail (Không đạt, lỗi)
  static const Color error = pviRed;
  static const Color errorDark = pviRedDark;
  static const Color errorSurface = pviRedSurface;
  static const Color errorBorder = pviRedBorder;
  static const Color onError = Color(0xFFFFFFFF);

  /// Info / Guide (Hướng dẫn, chi tiết kỹ thuật)
  static const Color info = pviBlue;
  static const Color infoDark = Color(0xFF003E7A);
  static const Color infoSurface = pviBlueSurface;
  static const Color infoBorder = pviBlueBorder;
  static const Color onInfo = Color(0xFFFFFFFF);

  /// Bề mặt trạng thái màu tối (dành cho các màn hình kiểm thử chế độ tối)
  static const Color successDarkSurface = Color(0xFF0A3E2F);
  static const Color infoDarkSurface = Color(0xFF0F2D4E);
  static const Color warningDarkSurface = Color(0xFF3F2B07);
  static const Color errorDarkSurface = Color(0xFF451113);

  // ===========================================================================
  // 3. SURFACE & BACKGROUND TOKENS (Nền & Viền thuần - 100% Solid)
  // ===========================================================================

  /// Nền chính toàn app (Clean light surface)
  static const Color background = Color(0xFFF4F7FB);

  /// Nền thẻ card / sheet
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8FAFC);
  static const Color surfaceSubtle = Color(0xFFEDF2F7);

  /// Viền tiêu chuẩn
  static const Color border = Color(0xFFDCE4EE);
  static const Color borderSubtle = Color(0xFFEBF0F5);
  static const Color borderStrong = Color(0xFFB8C9DC);

  // ===========================================================================
  // 4. TEXT & ICON COLOR HIERARCHY (Phân cấp chữ & biểu tượng)
  // ===========================================================================

  /// Tiêu đề chính, văn bản thương hiệu
  static const Color textPrimary = pviNavy;

  /// Nội dung thân bài, mô tả
  static const Color textSecondary = Color(0xFF334155);

  /// Chú thích, nhãn phụ, ngày tháng
  static const Color textMuted = Color(0xFF64748B);

  /// Chữ trên nền tối (Navy, Red, Primary button)
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Chữ trên nền thương hiệu
  static const Color textOnBrand = Color(0xFFFFFFFF);

  /// Chữ trạng thái vô hiệu hóa
  static const Color textDisabled = Color(0xFF94A3B8);

  /// Biểu tượng chính
  static const Color icon = pviBlue;
  static const Color iconMuted = Color(0xFF64748B);

  // ===========================================================================
  // 5. BASE & SOLID NEUTRALS (Màu cơ bản thuần)
  // ===========================================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Các sắc thái xám trung tính (Màu thuần, không alpha)
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGreyLight = Color(0xFFEEEEEE);
  static const Color neutralGreyLighter = Color(0xFFE0E0E0);
  static const Color neutralGreyMedium = Color(0xFFBDBDBD);
  static const Color neutralGrey = Color(0xFF9E9E9E);
  static const Color grey500 = neutralGrey;
  static const Color neutralGreyDark = Color(0xFF757575);
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);

  // Các màu xám thuần tương đương để thay thế màu trắng & đen trong suốt cũ
  static const Color white70 = Color(0xFFE2E8F0);
  static const Color white60 = Color(0xFFCBD5E1);
  static const Color white54 = Color(0xFFB8C9DC);
  static const Color white38 = Color(0xFF94A3B8);
  static const Color white30 = Color(0xFF64748B);
  static const Color white24 = Color(0xFF475569);
  static const Color white12 = Color(0xFF334155);
  static const Color white10 = Color(0xFF1E293B);

  static const Color black87 = Color(0xFF1E293B);
  static const Color black676767 = Color(0xFF676767);
  static const Color black54 = Color(0xFF64748B);
  static const Color black45 = Color(0xFF94A3B8);
  static const Color black38 = Color(0xFFCBD5E1);
  static const Color black26 = Color(0xFFE2E8F0);
  static const Color black12 = Color(0xFFF1F5F9);

  // Các màu chuẩn tương đương Material design
  static const Color amber = Color(0xFFFFC107);
  static const Color amberLight = Color(0xFFFFE082);
  static const Color amberDark = Color(0xFFFFA000);

  static const Color green = Color(0xFF4CAF50);
  static const Color greenLight = Color(0xFF81C784);
  static const Color greenDark = Color(0xFF388E3C);

  static const Color red = Color(0xFFF44336);
  static const Color redLight = Color(0xFFE57373);
  static const Color redDark = Color(0xFFD32F2F);

  static const Color blue = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFF64B5F6);
  static const Color blueDark = Color(0xFF1976D2);

  static const Color orange = Color(0xFFFF9800);
  static const Color orangeLight = Color(0xFFFFB74D);
  static const Color orangeDark = Color(0xFFF57C00);

  static const Color neutralPurple = Color(0xFF9C27B0);
  static const Color purple = neutralPurple;
  static const Color neutralTeal = Color(0xFF009688);
  static const Color teal = neutralTeal;
  static const Color neutralYellow = Color(0xFFFFEB3B);
  static const Color yellow = neutralYellow;
  static const Color neutralPink = Color(0xFFE91E63);
  static const Color pink = neutralPink;
  static const Color neutralCyan = Color(0xFF00BCD4);
  static const Color cyan = neutralCyan;
  static const Color neutralLightGreenAccent = Color(0xFFB9F6CA);

  // ===========================================================================
  // 6. TEST & DIAGNOSTICS UI SEMANTICS (Bí danh cho luồng kiểm định)
  // ===========================================================================

  static const Color pass = success;
  static const Color passLight = Color(0xFF66BB6A);
  static const Color passLighter = successSurface;
  static const Color passDark = successDark;
  static const Color passAccent = Color(0xFF69F0AE);

  static const Color fail = error;
  static const Color failLight = Color(0xFFEF5350);
  static const Color failLighter = errorSurface;
  static const Color failLightest = Color(0xFFEF9A9A);
  static const Color failDark = errorDark;
  static const Color failAccent = Color(0xFFFF5252);

  static const Color warningLight = Color(0xFFFFA726);
  static const Color warningLighter = warningSurface;
  static const Color warningDarker = Color(0xFFF57C00);

  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoLighter = infoSurface;
  static const Color infoMedium = Color(0xFF64B5F6);
  static const Color infoDarker = Color(0xFF0D47A1);

  // ===========================================================================
  // 7. BACKWARD COMPATIBILITY ALIASES (Tương thích mã nguồn hiện hữu)
  // ===========================================================================

  // Ý nghĩa màu Trade-in ánh xạ sang hệ màu PVI
  static const Color tradeInBlue = pviRed; // PVI Star Red CTA
  static const Color tradeInBlueLight = pviRedLight;
  static const Color tradeInNavy = pviNavy; // PVI Corporate Navy
  static const Color tradeInDark = pviNavyDark;
  static const Color tradeInSlate = Color(0xFF283E58);
  static const Color tradeInSlateLight = Color(0xFF6E8299);
  static const Color tradeInGold = warning;
  static const Color tradeInGoldDark = warningDark;
  static const Color tradeInGoldLight = warningSurface;
  static const Color tradeInEmerald = success;
  static const Color tradeInEmeraldLight = successSurface;
  static const Color tradeInEmeraldBorder = successBorder;
  static const Color tradeInSurfaceBg = background;
  static const Color tradeInBorder = border;

  // Các token màu của hệ thống thiết kế cũ
  static const Color neutral01 = Color(0xFF171717);
  static const Color neutral02 = Color(0xFF404040);
  static const Color neutral03 = Color(0xFF737373);
  static const Color neutral04 = Color(0xFFA3A3A3);
  static const Color neutral05 = Color(0xFFD4D4D4);
  static const Color neutral06 = Color(0xFFE6E6E6);
  static const Color neutral07 = Color(0xFFF5F5F5);
  static const Color neutral08 = Color(0xFFFAFAFA);

  static const Color AE01 = pviRed;
  static const Color AE02 = pviRedSurface;
  static const Color AW01 = warning;
  static const Color AW02 = warningSurface;
  static const Color AS01 = success;
  static const Color AS02 = successSurface;
  static const Color AB01 = pviBlue;
  static const Color AB02 = pviBlueSurface;

  static const Color primary01 = pviRed;
  static const Color primary02 = pviRedLight;
  static const Color primary03 = Color(0xFFFFC0C0);
  static const Color primary04 = pviRedSurface;
  static const Color primary05 = Color(0xFFFFFAFA);

  static const Color secondaryP01 = Color(0xFF662A00);
  static const Color secondaryP02 = Color(0xFF993F00);
  static const Color secondaryP03 = Color(0xFFCC5400);
  static const Color secondaryP05 = Color(0xFF287088);
  static const Color secondaryP04 = Color(0xFFEFEEFE);

  static const Color strokeKiemDinh = Color(0xFFFAEBF9);
  static const Color yellowFidoBox = Color(0xFFF1B522);
  static const Color yellowFidoBoxText = Color(0xFFF1AE0C);
  static const Color selectNavBar = Color(0xFFF6D723);
  static const Color textColorgray = Color(0xFF495057);
  static const Color selectTab = Color(0xFF454F5B);
  static const Color backgrounSubtab = Color(0xFFD7D7D7);
  static const Color bageColor = Color(0xFFFFE6B4);
  static const Color fifoSale = pviRed;
  static const Color backgroundFidoBoxSub = Color(0xFFF6F6F6);
  static const Color textNormal = Color(0xFF454F5B);
  static const Color textBage = Color(0xFFFFAB00);
  static const Color textDescription = Color(0xFFBEBEBE);

  static const Color text = textSecondary;
  static const Color disable = Color(0xFFEFF0F1);
  static const Color onDisable = Color(0xFFAAAAAA);

  static const Color gray5 = Color(0xFFFAFAFA);
  static const Color gray10 = Color(0xFFF3F4F4);
  static const Color gray20 = Color(0xFFEFF0F1);
  static const Color gray40 = Color(0xFFCCCCCC);
  static const Color gray60 = Color(0xFFAAAAAA);
  static const Color gray80 = Color(0xFF424242);

  static const Color gradientsBlue = Color(0xFF0199FE);
  static const Color gradientsRed = pviRed;
  static const Color gray8F8F8F = Color(0xFF8F8F8F);
  static const Color greyE5E5E5 = Color(0xFFE5E5E5);
  static const Color borderPopulate = Color(0xFFE5E5E5);
  static const Color redE82B2B = pviRed;
  static const Color gray595454 = Color(0xFF595454);
  static const Color blue4D81E7 = Color(0xFF4D81E7);
  static const Color gray898B8C = Color(0xFF898B8C);
  static const Color gray969696 = Color(0xFF969696);
  static const Color blue0F96FC = Color(0xFF0F96FC);
  static const Color grayEFEFF1 = Color(0xFFEFEFF1);
  static const Color gray67677A = Color(0xFF67677A);
  static const Color green03B134 = success;
  static const Color yellowFEA400 = Color(0xFFFEA400);
  static const Color yellowFBCE07 = Color(0xFFFBCE07);
  static const Color grayB5B7B8 = Color(0xFFB5B7B8);
  static const Color grayF3F3F3 = Color(0xFFF3F3F3);
  static const Color gradientsGreen1 = Color(0xFF000000);
  static const Color gradientsGreen2 = Color(0xFF06661C);
  static const Color primaryApp = pviNavy;
  static const Color blue006FFD = Color(0xFF006FFD);
  static const Color redFF616D = Color(0xFFFF616D);
  static const Color gray616161 = Color(0xFF616161);
  static const Color red700 = Color(0xFF890108);
  static const Color red600 = Color(0xFFB10710);
  static const Color slate5B7C99 = Color(0xFF5B7C99);

  // Dải chuyển màu cũ (giữ lại để tương thích ngược)
  static const LinearGradient secondaryGra01 = LinearGradient(
    colors: [Color(0xFFFBB379), Color(0xFFFE675C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
