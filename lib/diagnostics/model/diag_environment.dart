/// Diagnostic Environment - Tracks system state, permissions, services
class DiagEnvironment {
  final String brand;
  final String platform;
  final bool locationServiceOn;
  final Set<String> deniedPerms;
  final Set<String> grantedPerms;
  final Map<String, bool> sensors;

  const DiagEnvironment({
    this.brand = '',
    this.platform = 'android',
    this.locationServiceOn = false,
    this.deniedPerms = const {},
    this.grantedPerms = const {},
    this.sensors = const {},
  });

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

  bool get isMiui => brand.toLowerCase() == 'xiaomi';
  bool get isColorOs => brand.toLowerCase() == 'oppo';
  bool get isSamsung => brand.toLowerCase() == 'samsung';
  bool get isApple => brand.toLowerCase() == 'apple' || platform == 'ios';

  bool isPermDenied(String perm) => deniedPerms.contains(perm);
  bool isPermGranted(String perm) => grantedPerms.contains(perm);
  bool hasSensor(String sensor) => sensors[sensor] == true;
}
