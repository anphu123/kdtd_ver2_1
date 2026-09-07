/// ============================================================
/// DeviceInfoHelper - Hỗ Trợ Lấy Thông Tin Thiết Bị
/// ============================================================
///
/// File này cung cấp các helper để lấy thông tin thiết bị
/// với fallback cho iOS khi MethodChannel Android không hoạt động.
///
/// Bao gồm:
/// - RAM info (với estimation cho iOS)
/// - ROM info (với estimation cho iOS)
/// - Model mapping cho iOS devices
/// ============================================================
library;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.fidobox/diagnostics');

/// Helper class để lấy thông tin thiết bị đa nền tảng
class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ==================== RAM INFO ====================

  /// Lấy thông tin RAM
  /// - Android: Sử dụng MethodChannel
  /// - iOS: Ước tính dựa trên model
  static Future<Map<String, dynamic>> getRamInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidRamInfo();
    } else if (Platform.isIOS) {
      return _getIosRamInfo();
    }
    return const {'freeBytes': null, 'totalBytes': null, 'source': 'unknown'};
  }

  static Future<Map<String, dynamic>> _getAndroidRamInfo() async {
    try {
      final Map? raw = await _channel.invokeMethod<Map>('getRamInfo');
      if (raw == null) {
        return const {
          'freeBytes': null,
          'totalBytes': null,
          'source': 'android_null',
        };
      }
      return {
        'freeBytes': raw['freeBytes'] ?? raw['free_bytes'],
        'totalBytes': raw['totalBytes'] ?? raw['total_bytes'],
        'source': 'android_native',
      };
    } catch (e) {
      return {
        'freeBytes': null,
        'totalBytes': null,
        'source': 'android_error',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _getIosRamInfo() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;
      final ramGB = _estimateIosRam(iosInfo.utsname.machine);
      final totalBytes = (ramGB * 1024 * 1024 * 1024).toInt();

      return {
        'freeBytes': null, // iOS không cho phép đọc free RAM
        'totalBytes': totalBytes,
        'totalGB': ramGB,
        'source': 'ios_estimated',
        'model': iosInfo.utsname.machine,
      };
    } catch (e) {
      return {
        'freeBytes': null,
        'totalBytes': null,
        'source': 'ios_error',
        'error': e.toString(),
      };
    }
  }

  /// Ước tính RAM dựa trên model iOS
  /// Dữ liệu từ Apple specs
  static int _estimateIosRam(String machine) {
    // iPhone
    if (machine.startsWith('iPhone')) {
      final parts = machine.replaceAll('iPhone', '').split(',');
      final major = int.tryParse(parts[0]) ?? 0;

      // iPhone 15 Pro Max: iPhone16,2 -> 8GB
      if (major >= 16) return 8;
      // iPhone 14 Pro: iPhone15,3 -> 6GB
      if (major >= 15) return 6;
      // iPhone 13: iPhone14,x -> 4-6GB
      if (major >= 14) return 4;
      // iPhone 12: iPhone13,x -> 4GB
      if (major >= 13) return 4;
      // iPhone 11: iPhone12,x -> 4GB
      if (major >= 12) return 4;
      // iPhone X/XS: iPhone10,x/11,x -> 3-4GB
      if (major >= 10) return 3;
      // iPhone 7/8: iPhone9,x -> 2GB
      if (major >= 9) return 2;
      // Older -> 1-2GB
      return 2;
    }

    // iPad
    if (machine.startsWith('iPad')) {
      final parts = machine.replaceAll('iPad', '').split(',');
      final major = int.tryParse(parts[0]) ?? 0;

      // iPad Pro M2+: iPad14,x+ -> 8-16GB
      if (major >= 14) return 8;
      // iPad Air/Pro: iPad13,x -> 8GB
      if (major >= 13) return 8;
      // iPad: iPad12,x -> 4GB
      if (major >= 12) return 4;
      // Older
      return 4;
    }

    // Default
    return 4;
  }

  // ==================== ROM INFO ====================

  /// Lấy thông tin ROM (Storage)
  /// - Android: Sử dụng MethodChannel
  /// - iOS: Ước tính dựa trên model hoặc không chính xác
  static Future<Map<String, dynamic>> getRomInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidRomInfo();
    } else if (Platform.isIOS) {
      return _getIosRomInfo();
    }
    return const {'freeBytes': null, 'totalBytes': null, 'source': 'unknown'};
  }

  static Future<Map<String, dynamic>> _getAndroidRomInfo() async {
    try {
      final Map? raw = await _channel.invokeMethod<Map>('getRomInfo');
      if (raw == null) {
        return const {
          'freeBytes': null,
          'totalBytes': null,
          'source': 'android_null',
        };
      }
      return {
        'freeBytes': raw['freeBytes'] ?? raw['free_bytes'],
        'totalBytes': raw['totalBytes'] ?? raw['total_bytes'],
        'source': 'android_native',
      };
    } catch (e) {
      return {
        'freeBytes': null,
        'totalBytes': null,
        'source': 'android_error',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _getIosRomInfo() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;

      // iOS không cho phép đọc chính xác storage
      // Chúng ta có thể estimate dựa trên các mức phổ biến
      return {
        'freeBytes': null,
        'totalBytes': null,
        'source': 'ios_unavailable',
        'note': 'iOS không cho phép đọc dung lượng chính xác',
        'model': iosInfo.utsname.machine,
        'commonCapacities': [64, 128, 256, 512, 1024], // GB
      };
    } catch (e) {
      return {
        'freeBytes': null,
        'totalBytes': null,
        'source': 'ios_error',
        'error': e.toString(),
      };
    }
  }

  // ==================== SIGNAL STRENGTH ====================

  /// Lấy cường độ tín hiệu di động
  /// - Android: MethodChannel
  /// - iOS: Không khả dụng (Apple không cho phép)
  static Future<Map<String, dynamic>> getSignalStrength() async {
    if (Platform.isAndroid) {
      return _getAndroidSignalStrength();
    } else if (Platform.isIOS) {
      return _getIosSignalStrength();
    }
    return const {'dbm': null, 'bars': null, 'source': 'unknown'};
  }

  static Future<Map<String, dynamic>> _getAndroidSignalStrength() async {
    try {
      final int? dbm = await _channel.invokeMethod<int>('getSignalStrengthDbm');
      if (dbm == null) {
        return const {'dbm': null, 'source': 'android_null'};
      }
      return {'dbm': dbm, 'source': 'android_native'};
    } catch (e) {
      return {'dbm': null, 'source': 'android_error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _getIosSignalStrength() async {
    // iOS không cho phép đọc signal strength từ app thông thường
    return const {
      'dbm': null,
      'source': 'ios_unavailable',
      'note': 'iOS không cho phép đọc cường độ tín hiệu',
    };
  }

  // ==================== SIM INFO ====================

  /// Lấy thông tin SIM (Slot count & States)
  /// - Android: MethodChannel
  /// - iOS: Không public API, trả về default 1 slot
  static Future<Map<String, dynamic>> getSimInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidSimInfo();
    } else if (Platform.isIOS) {
      return _getIosSimInfo();
    }
    return const {'slotCount': 0, 'states': [], 'source': 'unknown'};
  }

  static Future<Map<String, dynamic>> _getAndroidSimInfo() async {
    try {
      final slots = await _channel.invokeMethod<int>('getSimSlotCount');
      final states = await _channel.invokeMethod<List>('getSimStates');
      return {
        'slotCount': slots ?? 0,
        'states': states ?? [],
        'source': 'android_native',
      };
    } catch (e) {
      return {
        'slotCount': 0,
        'states': [],
        'source': 'android_error',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _getIosSimInfo() async {
    // iOS không cho phép check SIM slots programmatic dễ dàng
    // Giả định ít nhất 1 slot (physical hoặc eSIM)
    // CoreTelephony có thể check carrier nhưng deprecated slot info
    return const {
      'slotCount': 1,
      'states': ['UNKNOWN'], // Không biết trạng thái
      'source': 'ios_default',
      'note': 'iOS không cho phép đọc thông tin khe SIM',
    };
  }

  // ==================== BRAND DETECTION ====================

  /// Lấy brand của thiết bị
  static Future<String> getBrand() async {
    if (Platform.isIOS) {
      return 'Apple';
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.brand;
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Lấy model của thiết bị
  static Future<String> getModel() async {
    if (Platform.isIOS) {
      try {
        final iosInfo = await _deviceInfo.iosInfo;
        return _mapIosModelName(iosInfo.utsname.machine);
      } catch (_) {
        return 'iPhone';
      }
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Map iOS machine identifier sang tên marketing
  static String _mapIosModelName(String machine) {
    // iPhone
    final iphoneMap = {
      'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone16,1': 'iPhone 15 Pro',
      'iPhone15,5': 'iPhone 15 Plus',
      'iPhone15,4': 'iPhone 15',
      'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone14,8': 'iPhone 14 Plus',
      'iPhone14,7': 'iPhone 14',
      'iPhone14,6': 'iPhone SE (3rd gen)',
      'iPhone14,5': 'iPhone 13',
      'iPhone14,4': 'iPhone 13 mini',
      'iPhone14,3': 'iPhone 13 Pro Max',
      'iPhone14,2': 'iPhone 13 Pro',
      'iPhone13,4': 'iPhone 12 Pro Max',
      'iPhone13,3': 'iPhone 12 Pro',
      'iPhone13,2': 'iPhone 12',
      'iPhone13,1': 'iPhone 12 mini',
      'iPhone12,8': 'iPhone SE (2nd gen)',
      'iPhone12,5': 'iPhone 11 Pro Max',
      'iPhone12,3': 'iPhone 11 Pro',
      'iPhone12,1': 'iPhone 11',
      'iPhone11,8': 'iPhone XR',
      'iPhone11,6': 'iPhone XS Max',
      'iPhone11,4': 'iPhone XS Max',
      'iPhone11,2': 'iPhone XS',
      'iPhone10,6': 'iPhone X',
      'iPhone10,5': 'iPhone 8 Plus',
      'iPhone10,4': 'iPhone 8',
      'iPhone10,3': 'iPhone X',
      'iPhone10,2': 'iPhone 8 Plus',
      'iPhone10,1': 'iPhone 8',
    };

    if (iphoneMap.containsKey(machine)) {
      return iphoneMap[machine]!;
    }

    // Fallback: Extract từ machine
    if (machine.startsWith('iPhone')) {
      return 'iPhone ($machine)';
    }
    if (machine.startsWith('iPad')) {
      return 'iPad ($machine)';
    }

    return machine;
  }

  // ==================== PLATFORM CHECK ====================

  /// Kiểm tra platform
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Lấy platform string
  static String get platform => Platform.isIOS ? 'ios' : 'android';
}
