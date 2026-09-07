/// ============================================================
/// DeviceProfile - Hồ Sơ Thiết Bị
/// ============================================================
///
/// File này định nghĩa class DeviceProfile để xác định:
/// - Các tính năng bắt buộc của từng dòng máy
/// - Phân loại tier (1-5) để đánh giá giá trị
/// - Cấu hình test tùy theo model
///
/// Dữ liệu được load từ assets/device_profiles.json
/// ============================================================

class DeviceProfile {
  /// Tên profile (thường là tên model hoặc dòng máy)
  final String name;

  /// Danh sách tính năng bắt buộc (vd: ['nfc', 'bio', 'spen'])
  final List<String> require;

  /// Thiết bị có hỗ trợ S-Pen không (Samsung Note/Ultra series)
  final bool sPen;

  /// Thiết bị có yêu cầu sinh trắc học không
  final bool bio;

  /// Thiết bị có yêu cầu khóa màn hình an toàn không
  final bool secureLock;

  /// Phân loại tier (1-5):
  /// - Tier 1: Flagship mới nhất (iPhone 15 Pro, S24 Ultra)
  /// - Tier 2: Flagship cũ 1-2 năm
  /// - Tier 3: Mid-range (mặc định)
  /// - Tier 4: Entry-level
  /// - Tier 5: Máy cũ/giá thấp
  final int tier;

  /// Có nên tự động test màn hình không (thay vì manual)
  final bool autoScreenTest;

  const DeviceProfile({
    required this.name,
    this.require = const [],
    this.sPen = false,
    this.bio = false,
    this.secureLock = false,
    this.tier = 3,
    this.autoScreenTest = false,
  });

  /// Tạo profile từ JSON
  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      name: json['name'] ?? 'default',
      require: (json['require'] as List<dynamic>?)?.cast<String>() ?? [],
      sPen: json['spen'] ?? false,
      bio: json['bio'] ?? false,
      secureLock: json['secure_lock'] ?? false,
      tier: json['tier'] ?? 3,
      autoScreenTest: json['auto_screen_test'] ?? false,
    );
  }

  /// Chuyển profile thành JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'require': require,
      'spen': sPen,
      'bio': bio,
      'secure_lock': secureLock,
      'tier': tier,
      'auto_screen_test': autoScreenTest,
    };
  }

  // ==================== HELPER METHODS ====================

  /// Kiểm tra thiết bị có yêu cầu tính năng cụ thể không
  bool requiresFeature(String feature) {
    return require.contains(feature);
  }

  /// Kiểm tra có phải tier 5 (máy cũ/giá thấp) không
  bool get isTier5 => tier == 5;

  /// Kiểm tra có phải tier 1-2 (flagship) không
  bool get isFlagship => tier <= 2;

  /// Kiểm tra có phải mid-range không
  bool get isMidRange => tier == 3;

  /// Có nên test màn hình tự động không
  /// Tier 5 luôn tự động test để tiết kiệm thời gian
  bool get shouldAutoTestScreen => autoScreenTest || tier == 5;

  /// Mô tả tier bằng tiếng Việt
  String get tierDescription {
    switch (tier) {
      case 1:
        return 'Flagship mới';
      case 2:
        return 'Flagship cũ';
      case 3:
        return 'Tầm trung';
      case 4:
        return 'Phổ thông';
      case 5:
        return 'Giá rẻ/Cũ';
      default:
        return 'Không xác định';
    }
  }
}
