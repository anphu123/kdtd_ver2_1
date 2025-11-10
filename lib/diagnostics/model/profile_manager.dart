import 'dart:convert';
import 'package:flutter/services.dart';
import 'device_profile.dart';

/// Profile Manager - Loads and manages device profiles
class ProfileManager {
  static ProfileManager? _instance;
  Map<String, DeviceProfile> _profiles = {};
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
      final json = await rootBundle.loadString('assets/diag_thresholds.json');
      final data = jsonDecode(json) as Map<String, dynamic>;

      // Load profiles
      final profilesData = data['requirements_by_profile'] as Map<String, dynamic>?;
      if (profilesData != null) {
        profilesData.forEach((key, value) {
          final profileJson = value as Map<String, dynamic>;
          profileJson['name'] = key;
          _profiles[key] = DeviceProfile.fromJson(profileJson);
        });
      }

      // Load brand quirks
      _brandQuirks = data['brand_quirks'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error loading profiles: $e');
      // Use default profile
      _profiles['default'] = const DeviceProfile(name: 'default');
    }
  }

  /// Get profile for a specific device model
  DeviceProfile getProfile(String modelName, String brand) {
    // Try exact model match first
    final normalizedModel = _normalizeModelName(modelName);
    if (_profiles.containsKey(normalizedModel)) {
      return _profiles[normalizedModel]!;
    }

    // Try partial match
    for (var entry in _profiles.entries) {
      if (normalizedModel.contains(entry.key) || entry.key.contains(normalizedModel)) {
        return entry.value;
      }
    }

    // Try brand-specific default
    final brandKey = '${brand.toLowerCase()}_default';
    if (_profiles.containsKey(brandKey)) {
      return _profiles[brandKey]!;
    }

    // Return default profile
    return _profiles['default'] ?? const DeviceProfile(name: 'default');
  }

  /// Get brand quirks/special behaviors
  Map<String, dynamic> getBrandQuirks(String brand) {
    final normalizedBrand = brand.toLowerCase();
    return (_brandQuirks[normalizedBrand] as Map<String, dynamic>?) ?? {};
  }

  /// Check if brand has specific quirk
  bool hasBrandQuirk(String brand, String quirk) {
    final quirks = getBrandQuirks(brand);
    return quirks[quirk] == true;
  }

  String _normalizeModelName(String model) {
    // Remove common prefixes and normalize
    return model
        .toLowerCase()
        .replaceAll('sm-', '')
        .replaceAll('mi ', '')
        .replaceAll('redmi ', 'redmi_')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  /// Get all available profiles
  List<DeviceProfile> getAllProfiles() {
    return _profiles.values.toList();
  }

  /// Check if model/brand combination requires location for WiFi
  bool requiresLocationForWifi(String brand) {
    return hasBrandQuirk(brand, 'wifi_requires_location');
  }

  /// Check if model/brand combination requires location for Bluetooth
  bool requiresLocationForBluetooth(String brand) {
    return hasBrandQuirk(brand, 'bt_requires_location');
  }

  /// Check if ROM blocks SIM API
  bool romBlocksSimApi(String brand) {
    return hasBrandQuirk(brand, 'rom_blocks_sim_api');
  }
}

