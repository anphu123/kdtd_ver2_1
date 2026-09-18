/// Hằng số cho service ước tính giá thu mua thiết bị.
class PriceEstimationConstants {
  PriceEstimationConstants._();

  /// URL API ước tính giá (fallback về tính local nếu lỗi).
  static const String apiBaseUrl = 'https://api.example.com';

  /// Timeout gọi API ước tính giá.
  static const Duration apiTimeout = Duration(seconds: 10);

  // ---- Điều chỉnh theo RAM/ROM ----
  /// Mốc RAM chuẩn (GB), vượt mốc này mỗi GB cộng thêm tiền.
  static const int ramBaselineGb = 4;

  /// Số tiền cộng thêm mỗi GB RAM vượt mốc chuẩn.
  static const double pricePerExtraRamGb = 200000;

  /// Mốc ROM chuẩn (GB), vượt mốc này mỗi bước cộng thêm tiền.
  static const int romBaselineGb = 64;

  /// Bước tính ROM (GB).
  static const int romStepGb = 64;

  /// Số tiền cộng thêm mỗi bước ROM vượt mốc chuẩn.
  static const double pricePerRomStep = 500000;

  // ---- Mốc điểm số (score) đánh giá độ hao mòn ----
  /// Điểm >= mốc này: máy xuất sắc.
  static const int scoreExcellentMin = 90;

  /// Điểm >= mốc này: máy tốt.
  static const int scoreGoodMin = 80;

  /// Điểm >= mốc này: máy khá.
  static const int scoreFairMin = 70;

  /// Điểm >= mốc này: máy trung bình (dưới mốc là kém).
  static const int scorePoorMin = 60;

  // ---- Hệ số giá theo điểm số (tương ứng các mốc score ở trên) ----
  static const double scoreMultiplierExcellent = 1.0;
  static const double scoreMultiplierGood = 0.85;
  static const double scoreMultiplierFair = 0.70;
  static const double scoreMultiplierPoor = 0.55;
  static const double scoreMultiplierBad = 0.40;

  // ---- Độ tin cậy ước tính theo điểm số (tương ứng các mốc score ở trên) ----
  static const double confidenceExcellent = 0.95;
  static const double confidenceGood = 0.90;
  static const double confidenceFair = 0.85;
  static const double confidencePoor = 0.75;
  static const double confidenceBad = 0.60;

  // ---- Điều chỉnh theo xuất xứ ----
  /// Giảm giá cho máy xuất xứ Trung Quốc (-10%).
  static const double originChinaMultiplier = 0.9;

  /// Giảm giá cho máy xuất xứ Việt Nam (-5%).
  static const double originVietnamMultiplier = 0.95;

  /// Biên độ dao động khoảng giá min/max quanh giá ước tính (+-10%).
  static const double priceRangeMargin = 0.1;

  // ---- Giá cơ bản theo model (VND) ----
  static const double basePriceSamsungS24 = 20000000;
  static const double basePriceSamsungS23 = 15000000;
  static const double basePriceSamsungS22 = 12000000;
  static const double basePriceSamsungS21 = 10000000;
  static const double basePriceSamsungS20 = 8000000;
  static const double basePriceSamsungA54 = 7000000;
  static const double basePriceSamsungA34 = 5000000;
  static const double basePriceSamsungFold = 25000000;
  static const double basePriceSamsungFlip = 15000000;
  static const double basePriceSamsungDefault = 5000000;

  static const double basePriceIphone15 = 25000000;
  static const double basePriceIphone14 = 20000000;
  static const double basePriceIphone13 = 15000000;
  static const double basePriceIphone12 = 12000000;
  static const double basePriceIphone11 = 10000000;
  static const double basePriceIphoneProMax = 30000000;
  static const double basePriceIphoneDefault = 15000000;

  static const double basePriceXiaomi14 = 12000000;
  static const double basePriceXiaomi13 = 10000000;
  static const double basePriceXiaomi12 = 8000000;
  static const double basePriceXiaomiDefault = 5000000;

  static const double basePriceOppoFind = 10000000;
  static const double basePriceOppoReno = 7000000;
  static const double basePriceOppoDefault = 4000000;

  /// Giá mặc định khi không xác định được hãng/model.
  static const double basePriceUnknown = 3000000;
}
