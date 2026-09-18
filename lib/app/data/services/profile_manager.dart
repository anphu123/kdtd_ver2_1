import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kdtd_ver2_1/gen/assets.gen.dart';
import '../model/device_profile.dart';

/// Quản lý hồ sơ thiết bị (Profile Manager) - Tải và quản lý cấu hình theo model máy
class ProfileManager {
  static ProfileManager? _instance;
  final Map<String, DeviceProfile> _profiles = {};
  Map<String, dynamic> _brandQuirks = {};

  ProfileManager._();

  static Future<ProfileManager> getInstance() async {
    if (_instance == null) {
      _instance = ProfileManager._();
      await _instance!._loadProfiles();
    }
    return _instance!;
  }

  Future<void> _loadProfiles() async {
    try {
      final json = await rootBundle.loadString(Assets.diagThresholds);
      final data = jsonDecode(json) as Map<String, dynamic>;

      // Tải danh sách hồ sơ thiết bị
      final profilesData =
          data['requirements_by_profile'] as Map<String, dynamic>?;
      if (profilesData != null) {
        profilesData.forEach((key, value) {
          final profileJson = value as Map<String, dynamic>;
          profileJson['name'] = key;
          _profiles[key] = DeviceProfile.fromJson(profileJson);
        });
      }

      // Tải các đặc tính riêng theo thương hiệu (brand quirks)
      _brandQuirks = data['brand_quirks'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('Error loading profiles: $e');
      // Dùng hồ sơ mặc định
      _profiles['default'] = const DeviceProfile(name: 'default');
    }
  }

  /// Lấy hồ sơ (profile) cho một model máy cụ thể
  DeviceProfile getProfile(String modelName, String brand) {
    // Thử khớp chính xác tên model trước
    final normalizedModel = _normalizeModelName(modelName);

    // Khắc phục: Tránh khớp tên model rỗng (sẽ khớp với tất cả)
    if (normalizedModel.isEmpty) {
      return _profiles['default'] ?? const DeviceProfile(name: 'default');
    }

    if (_profiles.containsKey(normalizedModel)) {
      return _profiles[normalizedModel]!;
    }

    // Thử khớp một phần tên (partial match)
    for (var entry in _profiles.entries) {
      // Không khớp nếu key là default hoặc rỗng
      if (entry.key == 'default' || entry.key.isEmpty) continue;

      if (normalizedModel.contains(entry.key) ||
          entry.key.contains(normalizedModel)) {
        return entry.value;
      }
    }

    // Thử lấy cấu hình mặc định theo thương hiệu
    final brandKey = '${brand.toLowerCase()}_default';
    if (_profiles.containsKey(brandKey)) {
      return _profiles[brandKey]!;
    }

    // Trả về hồ sơ mặc định
    return _profiles['default'] ?? const DeviceProfile(name: 'default');
  }

  /// Lấy các đặc tính riêng/hành vi đặc thù của thương hiệu
  Map<String, dynamic> getBrandQuirks(String brand) {
    final normalizedBrand = brand.toLowerCase();
    return (_brandQuirks[normalizedBrand] as Map<String, dynamic>?) ?? {};
  }

  /// Kiểm tra thương hiệu có đặc tính cụ thể không
  bool hasBrandQuirk(String brand, String quirk) {
    final quirks = getBrandQuirks(brand);
    return quirks[quirk] == true;
  }

  String _normalizeModelName(String model) {
    // Loại bỏ các tiền tố phổ biến và chuẩn hoá chuỗi
    return model
        .toLowerCase()
        .replaceAll('sm-', '')
        .replaceAll('mi ', '')
        .replaceAll('redmi ', 'redmi_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  /// Lấy danh sách tất cả các hồ sơ hiện có
  List<DeviceProfile> getAllProfiles() {
    return _profiles.values.toList();
  }

  /// Kiểm tra thương hiệu có yêu cầu quyền vị trí để quét WiFi không
  bool requiresLocationForWifi(String brand) {
    return hasBrandQuirk(brand, 'wifi_requires_location');
  }

  /// Kiểm tra thương hiệu có yêu cầu quyền vị trí để quét Bluetooth không
  bool requiresLocationForBluetooth(String brand) {
    return hasBrandQuirk(brand, 'bt_requires_location');
  }

  /// Kiểm tra bản ROM có chặn API đọc SIM không
  bool romBlocksSimApi(String brand) {
    return hasBrandQuirk(brand, 'rom_blocks_sim_api');
  }
}
