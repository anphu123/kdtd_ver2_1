/// Hằng số hệ số nhân giá theo tình trạng ngoại quan khảo sát máy cũ.
class CosmeticSurveyConstants {
  CosmeticSurveyConstants._();

  // ---- Hệ số theo tình trạng thân máy (BodyCondition) ----
  /// Thân máy như mới, không giảm giá.
  static const double bodyPristineMultiplier = 1.0;

  /// Thân máy có xước nhẹ.
  static const double bodyMinorScratchesMultiplier = 0.95;

  /// Thân máy móp/dented.
  static const double bodyDentedMultiplier = 0.85;

  // ---- Hệ số theo tình trạng màn hình (ScreenCondition) ----
  /// Màn hình hoàn hảo, không giảm giá.
  static const double screenFlawlessMultiplier = 1.0;

  /// Màn hình có xước.
  static const double screenScratchedMultiplier = 0.93;

  /// Màn hình nứt/vỡ.
  static const double screenCrackedMultiplier = 0.75;
}
