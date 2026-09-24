/// ============================================================
/// DeviceInfoHelper - Hỗ Trợ Lấy Thông Tin Thiết Bị
/// ============================================================
///
/// File này cung cấp các helper để lấy thông tin thiết bị
/// với fallback cho iOS khi MethodChannel Android không hoạt động.
///
/// Bao gồm:
/// - Thông tin RAM (kèm ước tính cho iOS)
/// - Thông tin ROM (kèm ước tính cho iOS)
/// - Ánh xạ model máy cho thiết bị iOS
/// ============================================================
library;

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const _channel = MethodChannel('com.fidobox/diagnostics');

/// Helper class để lấy thông tin thiết bị đa nền tảng
class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ==================== THÔNG TIN BỘ NHỚ RAM ====================

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
      final Map? raw = await _channel.invokeMethod<Map>('getRamInfo');
      final native = raw?['totalBytes'];
      if (native is num && native > 0) {
        return {
          'freeBytes': null, // iOS không cho phép đọc free RAM
          'totalBytes': native,
          'source': 'ios_native',
        };
      }
    } catch (_) {
      // Rơi xuống ước tính theo model bên dưới.
    }

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
    // Dòng iPhone
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
      // Đời cũ hơn -> 1-2GB
      return 2;
    }

    // Dòng iPad
    if (machine.startsWith('iPad')) {
      final parts = machine.replaceAll('iPad', '').split(',');
      final major = int.tryParse(parts[0]) ?? 0;

      // iPad Pro M2+: iPad14,x+ -> 8-16GB
      if (major >= 14) return 8;
      // iPad Air/Pro: iPad13,x -> 8GB
      if (major >= 13) return 8;
      // iPad: iPad12,x -> 4GB
      if (major >= 12) return 4;
      // Các đời cũ hơn
      return 4;
    }

    // Mặc định
    return 4;
  }

  // ==================== THÔNG TIN BỘ NHỚ TRONG ROM ====================

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
      final Map? raw = await _channel.invokeMethod<Map>('getRomInfo');
      final native = raw?['totalBytes'];
      if (native is num && native > 0) {
        return {
          'freeBytes': raw?['freeBytes'],
          'totalBytes': native,
          'source': 'ios_native',
        };
      }
    } catch (_) {
      // Rơi xuống nhánh "không đọc được" bên dưới.
    }

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

  // ==================== CƯỜNG ĐỘ TÍN HIỆU ====================

  /// Lấy cường độ tín hiệu di động
  /// - Android: Sử dụng MethodChannel
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

  // ==================== THÔNG TIN SIM ====================

  /// Lấy thông tin SIM (Số khe cắm & Trạng thái)
  /// - Android: Sử dụng MethodChannel
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

  // ==================== NHẬN DIỆN THƯƠNG HIỆU & DÒNG MÁY ====================

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
        final machine = iosInfo.utsname.machine;
        final mapped = _mapIosModelName(machine);
        if (mapped != null) return mapped;

        // Máy đời mới chưa kịp cập nhật vào bảng tĩnh ở trên -> tra online.
        final online = await _fetchIosModelNameOnline(machine);
        if (online != null) return online;

        if (machine.startsWith('iPhone')) return 'iPhone ($machine)';
        if (machine.startsWith('iPad')) return 'iPad ($machine)';
        return machine;
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

  /// Tra tên marketing từ API công khai ipsw.me khi mã máy chưa có trong
  /// bảng tĩnh (thiết bị đời mới). Trả về `null` nếu không có mạng hoặc
  /// API không có dữ liệu — khi đó [getModel] sẽ fallback về hiển thị mã máy.
  static Future<String?> _fetchIosModelNameOnline(String machine) async {
    try {
      final uri = Uri.parse('https://api.ipsw.me/v4/device/$machine');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final name = data['name'] as String?;
      return (name != null && name.isNotEmpty) ? name : null;
    } catch (_) {
      return null;
    }
  }

  /// Map iOS machine identifier sang tên marketing dùng bảng tĩnh.
  /// Trả về `null` nếu mã máy chưa có trong bảng (máy đời mới).
  static String? _mapIosModelName(String machine) {
    // Bảng ánh xạ mã máy iPhone
    final iphoneMap = {
      'iPhone18,5': 'iPhone 17e',
      'iPhone18,4': 'iPhone Air',
      'iPhone18,3': 'iPhone 17',
      'iPhone18,2': 'iPhone 17 Pro Max',
      'iPhone18,1': 'iPhone 17 Pro',
      'iPhone17,5': 'iPhone 16e',
      'iPhone17,4': 'iPhone 16 Plus',
      'iPhone17,3': 'iPhone 16',
      'iPhone17,2': 'iPhone 16 Pro Max',
      'iPhone17,1': 'iPhone 16 Pro',
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

    return iphoneMap[machine];
  }

  // ==================== KIỂM TRA NỀN TẢNG (HỆ ĐIỀU HÀNH) ====================

  /// Kiểm tra platform
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Lấy platform string
  static String get platform => Platform.isIOS ? 'ios' : 'android';
}
