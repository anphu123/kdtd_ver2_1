/// Device Information Model
///
/// Contains all device-related information
class DeviceInfo {
  final String? modelName;
  final String? brand;
  final String? manufacturer;
  final String platform;
  final String? osVersion;
  final String? imei;
  final Map<String, dynamic> additionalInfo;

  const DeviceInfo({
    this.modelName,
    this.brand,
    this.manufacturer,
    required this.platform,
    this.osVersion,
    this.imei,
    this.additionalInfo = const {},
  });

  /// Check if device is Android
  bool get isAndroid => platform.toLowerCase() == 'android';

  /// Check if device is iOS
  bool get isIOS => platform.toLowerCase() == 'ios';

  /// Check if device is Samsung
  bool get isSamsung =>
      brand?.toLowerCase() == 'samsung' ||
      manufacturer?.toLowerCase() == 'samsung';

  /// Check if device is Apple
  bool get isApple =>
      brand?.toLowerCase() == 'apple' ||
      manufacturer?.toLowerCase() == 'apple' ||
      isIOS;

  /// Display name for the device
  String get displayName {
    if (modelName != null && modelName!.isNotEmpty) {
      return modelName!;
    }
    if (brand != null && brand!.isNotEmpty) {
      return brand!;
    }
    return 'Unknown Device';
  }

  /// Create a copy with modified fields
  DeviceInfo copyWith({
    String? modelName,
    String? brand,
    String? manufacturer,
    String? platform,
    String? osVersion,
    String? imei,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DeviceInfo(
      modelName: modelName ?? this.modelName,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      platform: platform ?? this.platform,
      osVersion: osVersion ?? this.osVersion,
      imei: imei ?? this.imei,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'brand': brand,
      'manufacturer': manufacturer,
      'platform': platform,
      'osVersion': osVersion,
      'imei': imei,
      'additionalInfo': additionalInfo,
    };
  }

  /// Create from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      modelName: json['modelName'] as String?,
      brand: json['brand'] as String?,
      manufacturer: json['manufacturer'] as String?,
      platform: json['platform'] as String? ?? 'unknown',
      osVersion: json['osVersion'] as String?,
      imei: json['imei'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(modelName: $modelName, brand: $brand, platform: $platform)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo &&
        other.modelName == modelName &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(modelName, platform);
}

