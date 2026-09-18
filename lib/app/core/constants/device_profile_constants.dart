/// Hằng số phân loại tier của DeviceProfile.
class DeviceProfileConstants {
  DeviceProfileConstants._();

  /// Tier <= giá trị này được coi là flagship (1-2).
  static const int flagshipTierMax = 2;

  /// Tier được coi là mid-range.
  static const int midRangeTier = 3;

  /// Tier máy cũ/giá thấp, luôn tự động test màn hình.
  static const int lowEndTier = 5;
}
