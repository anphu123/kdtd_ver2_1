import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';

import 'package:kdtd_ver2_1/app/core/constants/cosmetic_survey_constants.dart';

/// Model quản lý kết quả khảo sát tình trạng ngoại quan sơ bộ của khách hàng
enum BodyCondition {
  pristine(
    id: 'pristine',
    priceMultiplier: CosmeticSurveyConstants.bodyPristineMultiplier,
  ),
  minorScratches(
    id: 'minor_scratches',
    priceMultiplier: CosmeticSurveyConstants.bodyMinorScratchesMultiplier,
  ),
  dented(
    id: 'dented',
    priceMultiplier: CosmeticSurveyConstants.bodyDentedMultiplier,
  );

  final String id;
  final double priceMultiplier;

  const BodyCondition({required this.id, required this.priceMultiplier});

  String get label => 'cosmetic_survey.body_${id}_label'.trans();
  String get description => 'cosmetic_survey.body_${id}_description'.trans();
}

enum ScreenCondition {
  flawless(
    id: 'flawless',
    priceMultiplier: CosmeticSurveyConstants.screenFlawlessMultiplier,
  ),
  scratched(
    id: 'scratched',
    priceMultiplier: CosmeticSurveyConstants.screenScratchedMultiplier,
  ),
  cracked(
    id: 'cracked',
    priceMultiplier: CosmeticSurveyConstants.screenCrackedMultiplier,
  );

  final String id;
  final double priceMultiplier;

  const ScreenCondition({required this.id, required this.priceMultiplier});

  String get label => 'cosmetic_survey.screen_${id}_label'.trans();
  String get description => 'cosmetic_survey.screen_${id}_description'.trans();
}

enum AccountStatus {
  readyToLogOut(id: 'ready', isEligible: true),
  lockedOrForgotten(id: 'locked', isEligible: false);

  final String id;
  final bool isEligible;

  const AccountStatus({required this.id, required this.isEligible});

  String get label => 'cosmetic_survey.account_${id}_label'.trans();
  String get description => 'cosmetic_survey.account_${id}_description'.trans();
}

class DeviceCosmeticSurvey {
  BodyCondition body;
  ScreenCondition screen;
  AccountStatus account;

  DeviceCosmeticSurvey({
    this.body = BodyCondition.pristine,
    this.screen = ScreenCondition.flawless,
    this.account = AccountStatus.readyToLogOut,
  });

  double get totalMultiplier => body.priceMultiplier * screen.priceMultiplier;
}
