/// Device Profile - Defines requirements for specific device models
class DeviceProfile {
  final String name;
  final List<String> require; // Required features/tests
  final bool sPen;
  final bool bio;
  final bool secureLock;
  final int tier; // 1-5: Loại máy (1=cao cấp, 5=cũ/giá thấp)
  final bool autoScreenTest; // True = tự động test màn hình

  const DeviceProfile({
    required this.name,
    this.require = const [],
    this.sPen = false,
    this.bio = false,
    this.secureLock = false,
    this.tier = 3,
    this.autoScreenTest = false,
  });

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

  bool requiresFeature(String feature) {
    return require.contains(feature);
  }

  bool get isTier5 => tier == 5;
  bool get shouldAutoTestScreen => autoScreenTest || tier == 5;
}


