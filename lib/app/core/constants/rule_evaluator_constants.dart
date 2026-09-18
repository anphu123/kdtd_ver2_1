/// Hằng số dùng trong RuleEvaluator (đánh giá kết quả kiểm định).
class RuleEvaluatorConstants {
  RuleEvaluatorConstants._();

  // ---- Phân loại thế hệ sóng di động (radio generation) ----
  /// Từ khóa nhận diện sóng 2G.
  static const List<String> radio2GKeywords = [
    'GPRS',
    'EDGE',
    'GSM',
    'CDMA',
    '1X',
  ];

  /// Từ khóa nhận diện sóng 3G.
  static const List<String> radio3GKeywords = [
    'UMTS',
    'HSPA',
    'HSDPA',
    'HSUPA',
    'HSPAP',
    'EVDO',
  ];

  /// Từ khóa nhận diện sóng 4G.
  static const List<String> radio4GKeywords = ['LTE', 'WIMAX'];

  /// Từ khóa nhận diện sóng 5G.
  static const List<String> radio5GKeywords = ['NR', '5G'];

  /// Thế hệ sóng tối thiểu được chấp nhận (dưới 3G là fail).
  static const int minAcceptableRadioGeneration = 3;

  // ---- Pin ----
  /// Mức pin tối thiểu hợp lệ (%).
  static const num minBatteryLevel = 0;

  /// Mức pin tối đa hợp lệ (%).
  static const num maxBatteryLevel = 100;

  // ---- Bộ nhớ (ROM) ----
  /// Số byte trong 1 GB, dùng để đổi freeBytes sang GB.
  static const int bytesPerGigabyte = 1024 * 1024 * 1024;

  /// Cảnh báo nếu dung lượng trống dưới mốc này (GB), không làm fail test.
  static const double lowFreeStorageWarningGb = 1;

  // ---- Phân loại lỗi màn hình trong (nghiêm trọng, luôn fail) ----
  static const List<String> innerScreenDefectKeywords = [
    'Dead pixel',
    'Dead Pixel',
    'Bright pixel',
    'Bright Pixel',
    'Chảy mực',
    'Burn-in',
    'Vết ám',
    'Color Banding',
    'Nhấp nháy',
    'Flickering',
  ];

  // ---- Phân loại mức độ lỗi màn hình ngoài ----
  static const List<String> shatteredKeywords = ['vỡ', 'shattered'];
  static const List<String> crackKeywords = ['nứt', 'crack'];
  static const List<String> scratchKeywords = ['xước', 'scratch'];

  /// Số vết nứt từ mốc này trở lên coi là nghiêm trọng (severe).
  static const int severeCrackCountMin = 3;

  /// Số vết xước từ mốc này trở lên (kèm có nứt) coi là trung bình (moderate).
  static const int moderateScratchCountMin = 10;

  /// Nhãn mức độ lỗi màn hình ngoài.
  static const String screenSeveritySevere = 'severe';
  static const String screenSeverityModerate = 'moderate';
  static const String screenSeverityMinor = 'minor';
  static const String screenSeverityNone = 'none';
}
