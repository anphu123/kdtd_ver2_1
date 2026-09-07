// Mã màu cảnh báo (AE01, AW02, ...) đặt tên theo design token gốc thay vì
// lowerCamelCase — giữ nguyên để khớp với bảng màu thiết kế.
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  //linear gradient
  static const LinearGradient secondaryGra01 = LinearGradient(
    colors: [Color(0xFFFBB379), Color(0xFFFE675C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  //Palette color
  // neutral
  static const Color neutral01 = Color(0xFF171717);
  static const Color neutral02 = Color(0xFF404040);
  static const Color neutral03 = Color(0xFF737373);
  static const Color neutral04 = Color(0xFFA3A3A3);
  static const Color neutral05 = Color(0xFFD4D4D4);
  static const Color neutral06 = Color(0xFFE6E6E6);
  static const Color neutral07 = Color(0xFFF5F5F5);
  static const Color neutral08 = Color(0xFFFAFAFA);

  // Alerts/Errors
  static const Color AE01 = Color(0xFFE92525);
  static const Color AE02 = Color(0xFFFFF0F0);
  // Alerts/Warnings
  static const Color AW01 = Color(0xFFEFB500);
  static const Color AW02 = Color(0xFFFEF7DC);
  // Alerts/Success
  static const Color AS01 = Color(0xFF14BD33);
  static const Color AS02 = Color(0xFFE7F7EF);
  // Alerts/blue
  static const Color AB01 = Color(0xFF0A68FF);
  static const Color AB02 = Color(0xFFE8F1FF);

  // primary
  static const Color primary01 = Color(0xFFD00000);
  static const Color primary02 = Color(0xFFFF5050);
  static const Color primary03 = Color(0xFFFFC0C0);
  static const Color primary04 = Color(0xFFFFF0F0);
  static const Color primary05 = Color(0xffFFFAFA);

  // secondary P
  static const Color secondaryP01 = Color(0xFF662A00);
  static const Color secondaryP02 = Color(0xFF993F00);
  static const Color secondaryP03 = Color(0xFFCC5400);
  static const Color secondaryP05 = Color(0xFF287088);
  static const Color secondaryP04 = Color(0xFFEFEEFE);

  // stroke kiem dinh
  static const Color strokeKiemDinh = Color(0xFFFAEBF9);

  // fido_box
  static const Color yellowFidoBox = Color(0xFFF1B522);
  static const Color yellowFidoBoxText = Color(0xFFF1AE0C);
  static const Color selectNavBar = Color(0xFFF6D723);
  static const Color textColorgray = Color(0xFF495057);
  static const Color selectTab = Color(0xFF454F5B);
  static const Color backgrounSubtab = Color(0xFFD7D7D7);
  static const Color bageColor = Color(0xFFFFE6B4);
  static const Color fifoSale = Color(0xFFFF0000);
  static const Color backgroundFidoBoxSub = Color(0xFFF6F6F6);
  // Text fido_box
  static const Color textNormal = Color(0xFF454F5B);
  static const Color textBage = Color(0xFFFFAB00);
  static const Color textDescription = Color(0xFFBEBEBE);

  // System
  static const Color primary = Color(0xFF276992);
  static const Color onPrimary = Color(0xFF6F9DBA);
  static const Color text = Color(0xFF4A5155);
  static const Color icon = Color(0xFF67A8C4);
  static const Color success = Color(0xFF7CB5A3);
  static const Color onSuccess = Color(0xFFD5E8E1);
  static const Color error = Color(0xFFD96554);
  static const Color onError = Color(0xFFECDAD7);

  static const Color disable = gray20;
  static const Color onDisable = gray60;

  // Grays
  static const Color gray5 = Color(0xFFFAFAFA);
  static const Color gray10 = Color(0xFFF3F4F4);
  static const Color gray20 = Color(0xFFEFF0F1);
  static const Color gray40 = Color(0xFFCCCCCC);
  static const Color gray60 = Color(0xFFAAAAAA);
  static const Color gray80 = Color(0xFF424242);

  // Background
  static const Color background = Color(0xFFE5E5E5);

  // Color app
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black45 = Color(0x73000000);
  static const Color black38 = Color(0x61000000);
  static const Color black26 = Color(0x42000000);
  static const Color black12 = Color(0x1F000000);

  static const Color gradientsBlue = Color(0xFF0199FE);
  static const Color gradientsRed = Color(0xFFCC0102);
  static const Color gray8F8F8F = Color(0xFF8F8F8F);
  static const Color greyE5E5E5 = Color(0xFFE5E5E5);
  static const Color borderPopulate = Color(0xFFE5E5E5);
  static const Color black676767 = Color(0xFF676767);
  static const Color redE82B2B = Color(0xFFE82B2B);
  static const Color gray595454 = Color(0xFF595454);
  static const Color blue4D81E7 = Color(0xFF4D81E7);
  static const Color gray898B8C = Color(0xFF898B8C);
  static const Color gray969696 = Color(0xFF969696);
  static const Color transparent = Color(0x00000000);
  static const Color blue0F96FC = Color(0xFF0F96FC);
  static const Color grayEFEFF1 = Color(0xFFEFEFF1);
  static const Color gray67677A = Color(0xFF67677A);
  static const Color green03B134 = Color(0xFF03B134);
  static const Color yellowFEA400 = Color(0xFFFEA400);
  static const Color yellowFBCE07 = Color(0xFFFBCE07);
  static const Color grayE5E5E5 = Color(0xFFE5E5E5);
  static const Color grayB5B7B8 = Color(0xFFB5B7B8);
  static const Color grayF3F3F3 = Color(0xFFF3F3F3);
  static const Color gradientsGreen1 = Color(0xFF000000);
  static const Color gradientsGreen2 = Color(0xFF06661C);
  static const Color primaryApp = Color(0xFF06661C);
  static const Color blue006FFD = Color(0xFF006FFD);
  static const Color redFF616D = Color(0xFFFF616D);
  static const Color gray616161 = Color(0xFF616161);
  static const Color red700 = Color(0xFF890108);
  static const Color red600 = Color(0xFFB10710);
  static const Color slate5B7C99 = Color(0xFF5B7C99);

  // Standard Material palette equivalents
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

  // ==================== Test/Diagnostics UI ====================
  // Bí danh cho các màu dùng ở các màn test (pass/fail/warning/info...)
  // Giữ đúng sắc độ thiết kế, đặt tên ngữ nghĩa thay vì gọi thẳng Colors.*.
  static const Color pass = Color(0xFF4CAF50); // Colors.green
  static const Color passLight = Color(0xFF66BB6A); // Colors.green.shade400
  static const Color passLighter = Color(0xFFE8F5E9); // Colors.green.shade50
  static const Color passDark = Color(0xFF388E3C); // Colors.green.shade700
  static const Color passAccent = Color(0xFF69F0AE); // Colors.greenAccent

  static const Color fail = Color(0xFFF44336); // Colors.red
  static const Color failLight = Color(0xFFEF5350); // Colors.red.shade400
  static const Color failLighter = Color(0xFFFFEBEE); // Colors.red.shade50
  static const Color failLightest = Color(0xFFEF9A9A); // Colors.red.shade200
  static const Color failDark = Color(0xFFD32F2F); // Colors.red.shade700
  static const Color failAccent = Color(0xFFFF5252); // Colors.redAccent

  static const Color warning = Color(0xFFFF9800); // Colors.orange
  static const Color warningLight = Color(0xFFFFA726); // Colors.orange.shade400
  static const Color warningLighter = Color(0xFFFFF3E0); // Colors.orange.shade50
  static const Color warningDark = Color(0xFFFB8C00); // Colors.orange.shade600
  static const Color warningDarker = Color(0xFFF57C00); // Colors.orange.shade700

  static const Color info = Color(0xFF2196F3); // Colors.blue
  static const Color infoLighter = Color(0xFFE3F2FD); // Colors.blue.shade50
  static const Color infoLight = Color(0xFF90CAF9); // Colors.blue.shade200
  static const Color infoMedium = Color(0xFF64B5F6); // Colors.blue.shade300
  static const Color infoDark = Color(0xFF1976D2); // Colors.blue.shade700
  static const Color infoDarker = Color(0xFF0D47A1); // Colors.blue.shade900

  static const Color neutralGrey = Color(0xFF9E9E9E); // Colors.grey / grey[500]
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGreyLighter = Color(0xFFE0E0E0); // grey.shade300 / grey[300]
  static const Color neutralGreyLight = Color(0xFFEEEEEE); // Colors.grey.shade200
  static const Color neutralGreyMedium = Color(0xFFBDBDBD); // Colors.grey.shade400
  static const Color neutralGreyDark = Color(0xFF757575); // grey.shade600 / grey[600]
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);

  static const Color neutralPurple = Color(0xFF9C27B0); // Colors.purple
  static const Color purple = neutralPurple;
  static const Color neutralTeal = Color(0xFF009688); // Colors.teal
  static const Color teal = neutralTeal;
  static const Color neutralYellow = Color(0xFFFFEB3B); // Colors.yellow
  static const Color yellow = neutralYellow;
  static const Color neutralPink = Color(0xFFE91E63); // Colors.pink
  static const Color pink = neutralPink;
  static const Color neutralCyan = Color(0xFF00BCD4); // Colors.cyan
  static const Color cyan = neutralCyan;
  static const Color neutralLightGreenAccent = Color(0xFFB9F6CA); // Colors.lightGreenAccent

  // ==================== Trade-In & Upgrade UI ====================
  static const Color tradeInNavy = Color(0xFF0F172A); // Slate 900
  static const Color tradeInDark = Color(0xFF1E293B); // Slate 800
  static const Color tradeInSlate = Color(0xFF334155); // Slate 700
  static const Color tradeInSlateLight = Color(0xFF94A3B8); // Slate 400
  static const Color tradeInBlue = Color(0xFF2563EB); // Royal Blue
  static const Color tradeInBlueLight = Color(0xFF3B82F6);
  static const Color tradeInGold = Color(0xFFF59E0B); // Amber/Gold Voucher
  static const Color tradeInGoldDark = Color(0xFFD97706);
  static const Color tradeInGoldLight = Color(0xFFFEF3C7);
  static const Color tradeInEmerald = Color(0xFF10B981); // Emerald Pass Green
  static const Color tradeInEmeraldLight = Color(0xFFD1FAE5);
  static const Color tradeInSurfaceBg = Color(0xFFF8FAFC); // Clean slate white
  static const Color tradeInBorder = Color(0xFFE2E8F0);
}
