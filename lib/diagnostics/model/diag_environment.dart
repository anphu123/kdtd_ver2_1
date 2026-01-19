/// ============================================================
/// DiagEnvironment - Môi Trường Kiểm Định
/// ============================================================
///
/// File này định nghĩa class DiagEnvironment để theo dõi:
/// - Thông tin hệ thống (brand, platform)
/// - Trạng thái dịch vụ (location, sensors)
/// - Quyền ứng dụng (granted/denied permissions)
///
/// Được sử dụng bởi RuleEvaluator để đánh giá kết quả test.
/// ============================================================

class DiagEnvironment {
  /// Tên hãng sản xuất (samsung, xiaomi, oppo, apple...)
  final String brand;

  /// Nền tảng hệ điều hành (android, ios)
  final String platform;

  /// Dịch vụ vị trí có đang bật không
  final bool locationServiceOn;

  /// Danh sách quyền bị từ chối
  final Set<String> deniedPerms;

  /// Danh sách quyền đã được cấp
  final Set<String> grantedPerms;

  /// Danh sách cảm biến có sẵn trên thiết bị
  final Map<String, bool> sensors;

  const DiagEnvironment({
    this.brand = '',
    this.platform = 'android',
    this.locationServiceOn = false,
    this.deniedPerms = const {},
    this.grantedPerms = const {},
    this.sensors = const {},
  });

  /// Tạo bản sao với một số thuộc tính thay đổi
  DiagEnvironment copyWith({
    String? brand,
    String? platform,
    bool? locationServiceOn,
    Set<String>? deniedPerms,
    Set<String>? grantedPerms,
    Map<String, bool>? sensors,
  }) {
    return DiagEnvironment(
      brand: brand ?? this.brand,
      platform: platform ?? this.platform,
      locationServiceOn: locationServiceOn ?? this.locationServiceOn,
      deniedPerms: deniedPerms ?? this.deniedPerms,
      grantedPerms: grantedPerms ?? this.grantedPerms,
      sensors: sensors ?? this.sensors,
    );
  }

  // ==================== BRAND HELPERS ====================

  /// Kiểm tra có phải Xiaomi/MIUI không (cần xử lý đặc biệt cho Bluetooth)
  bool get isMiui =>
      brand.toLowerCase().contains('xiaomi') ||
      brand.toLowerCase().contains('redmi');

  /// Kiểm tra có phải OPPO/ColorOS không
  bool get isColorOs =>
      brand.toLowerCase().contains('oppo') ||
      brand.toLowerCase().contains('realme');

  /// Kiểm tra có phải Samsung/OneUI không
  bool get isSamsung => brand.toLowerCase().contains('samsung');

  /// Kiểm tra có phải Apple/iOS không
  bool get isApple =>
      brand.toLowerCase().contains('apple') || platform == 'ios';

  /// Kiểm tra có phải Huawei không (thường không có Google Services)
  bool get isHuawei =>
      brand.toLowerCase().contains('huawei') ||
      brand.toLowerCase().contains('honor');

  // ==================== PERMISSION HELPERS ====================

  /// Kiểm tra quyền có bị từ chối không
  bool isPermDenied(String perm) => deniedPerms.contains(perm);

  /// Kiểm tra quyền đã được cấp chưa
  bool isPermGranted(String perm) => grantedPerms.contains(perm);

  /// Kiểm tra thiết bị có cảm biến cụ thể không
  bool hasSensor(String sensor) => sensors[sensor] == true;
}
