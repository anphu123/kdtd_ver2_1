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
  static const Color black = Color(0xFF000000);
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
  static const Color transparent = Colors.transparent;
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
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF00629E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFecf9ff),
  onPrimaryContainer: Color.fromARGB(255, 3, 8, 12),
  secondary: Color(0xFF526070),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD5E4F7),
  onSecondaryContainer: Color(0xFF0F1D2A),
  tertiary: Color(0xFF695779),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFF0DBFF),
  onTertiaryContainer: Color(0xFF241532),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF1A1C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF1A1C1E),
  surfaceVariant: Color(0xFFDEE3EB),
  onSurfaceVariant: Color(0xFF42474E),
  outline: Color(0xFF72777F),
  onInverseSurface: Color(0xFFF1F0F4),
  inverseSurface: Color(0xFF2F3033),
  inversePrimary: Color(0xFF99CBFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF00629E),
  outlineVariant: Color(0xFFC2C7CF),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF99CBFF),
  onPrimary: Color(0xFF003355),
  primaryContainer: Color(0xFF004A78),
  onPrimaryContainer: Color(0xFFCFE5FF),
  secondary: Color(0xFFBAC8DA),
  onSecondary: Color(0xFF243240),
  secondaryContainer: Color(0xFF3A4857),
  onSecondaryContainer: Color(0xFFD5E4F7),
  tertiary: Color(0xFFD4BEE6),
  onTertiary: Color(0xFF392A49),
  tertiaryContainer: Color(0xFF514060),
  onTertiaryContainer: Color(0xFFF0DBFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1A1C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF1A1C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF42474E),
  onSurfaceVariant: Color(0xFFC2C7CF),
  outline: Color(0xFF8C9199),
  onInverseSurface: Color(0xFF1A1C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF00629E),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF99CBFF),
  outlineVariant: Color(0xFF42474E),
  scrim: Color(0xFF000000),
);
