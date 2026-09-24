import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:kdtd_ver2_1/app/core/constants/diagnostics_constants.dart';
import 'package:kdtd_ver2_1/app/data/services/device_info_helper.dart';
import 'package:kdtd_ver2_1/app/data/services/diag_logger.dart';
import 'package:kdtd_ver2_1/app/data/services/permission_gate.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/data/services/phone_info_service.dart';

/// Dịch vụ đọc thông số phần cứng, kết nối mạng và cảm biến native của thiết bị.
/// Tách biệt hoàn toàn logic platform/native ra khỏi controller.
class DeviceHardwareService {
  DeviceHardwareService._();

  static final Battery _battery = Battery();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const MethodChannel _channel = MethodChannel(
    DiagnosticsConstants.methodChannelName,
  );

  static Future<T?> _invoke<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } catch (_) {
      return null;
    }
  }

  /// Lấy Device ID duy nhất của thiết bị
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final nativeId = await _invoke<String>('getDeviceId');
        if (nativeId != null && nativeId.isNotEmpty) {
          return nativeId;
        }
        final a = await _deviceInfo.androidInfo;
        return a.id;
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        return i.identifierForVendor ?? i.utsname.machine;
      }
    } catch (e) {
      DiagLogger.warning('device_id', 'Lỗi lấy deviceId: $e');
    }
    return 'unknown';
  }

  /// Thu thập thông tin hệ điều hành, model, brand và marketing name
  static Future<Map<String, dynamic>> getOsAndModel({
    void Function(String marketingName)? onMarketingNameFetched,
  }) async {
    try {
      final deviceId = await getDeviceId();

      if (Platform.isAndroid) {
        final a = await _deviceInfo.androidInfo;
        final vendor = a.manufacturer.toLowerCase();
        final marketingName =
            a.brand.isNotEmpty &&
                    !a.model.toLowerCase().contains(a.brand.toLowerCase())
                ? '${a.brand.toUpperCase()} ${a.model}'
                : a.model;

        // Bất đồng bộ lấy marketing name từ API
        PhoneInfoService.getMarketingName(a.model, a.brand).then((name) {
          if (name != null && name.isNotEmpty && onMarketingNameFetched != null) {
            onMarketingNameFetched(name);
          }
        }).catchError((e) {
          DiagLogger.warning('phoneinfo', 'Lỗi lấy marketing name từ API: $e');
        });

        return {
          'platform': 'android',
          'deviceId': deviceId,
          'sdk': a.version.sdkInt,
          'release': a.version.release,
          'model': a.model,
          'marketingName': marketingName,
          'brand': a.brand,
          'manufacturer': a.manufacturer,
          'vendor': vendor,
          'isSamsung': vendor == 'samsung',
          'isApple': false,
        };
      } else if (Platform.isIOS) {
        final i = await _deviceInfo.iosInfo;
        final machine = i.utsname.machine;
        final friendlyName = await DeviceInfoHelper.getModel();

        return {
          'platform': 'ios',
          'deviceId': deviceId,
          'systemVersion': i.systemVersion,
          'model': machine,
          'marketingName': friendlyName,
          'name': i.name,
          'brand': 'Apple',
          'manufacturer': 'Apple',
          'vendor': 'apple',
          'isSamsung': false,
          'isApple': true,
        };
      }
      return {'platform': 'unknown', 'deviceId': deviceId};
    } catch (e) {
      DiagLogger.error('osmodel', 'Lỗi lấy thông tin OS: $e');
      return {'platform': 'error', 'error': e.toString(), 'deviceId': 'unknown'};
    }
  }

  /// Thông tin Pin (mức sạc và trạng thái)
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return {'level': level, 'state': state.name};
  }

  /// Nguồn sạc (USB/AC/Wireless)
  static Future<Map<String, dynamic>> getChargingInfo() async {
    final state = await _battery.batteryState;
    final src = await _invoke<String>('getChargingSource');
    return {'state': state.name, 'source': src};
  }

  /// Trạng thái Wi-Fi
  static Future<Map<String, dynamic>> getWifiInfo() async {
    final wifiEnabled = await _invoke<bool>('isWifiEnabled');
    final conn = await Connectivity().checkConnectivity();
    final onWifi =
        conn.contains(ConnectivityResult.wifi) ||
        conn.contains(ConnectivityResult.ethernet);
    String? ssid;
    var permissionDenied = false;
    if (onWifi) {
      try {
        if (await PermissionGate.ensure(
          Permission.locationWhenInUse,
          name: LocaleKeys.permission_location_name.trans(),
        )) {
          ssid = await NetworkInfo().getWifiName();
        } else {
          permissionDenied = true;
        }
      } catch (_) {}
    }
    return {
      'enabled': wifiEnabled ?? onWifi,
      'connected': onWifi,
      'ssid': ssid,
      'permissionDenied': permissionDenied,
    };
  }

  /// Trạng thái Mạng di động (sóng, radio 3G/4G/5G)
  static Future<Map<String, dynamic>> getMobileNetworkInfo() async {
    if (!await PermissionGate.ensure(
      Permission.phone,
      name: LocaleKeys.permission_phone_name.trans(),
    )) {
      DiagLogger.warning('mobile', 'Không có quyền READ_PHONE_STATE');
      return {'connected': false, 'error': 'permission_denied'};
    }

    final conn = await Connectivity().checkConnectivity();
    final onMobile = conn.contains(ConnectivityResult.mobile);
    int? dbm;
    String? radio;
    if (onMobile) {
      final sig = await DeviceInfoHelper.getSignalStrength();
      dbm = sig['dbm'];
      radio = await _invoke<String>('getMobileRadioType');
    }
    return {'connected': onMobile, 'dbm': dbm, 'radio': radio};
  }

  /// Kiểm tra loại sóng di động có đạt 3G trở lên không
  static bool is3GOrHigher(String radio) {
    return DiagnosticsConstants.radios3GOrHigher.contains(radio.toUpperCase());
  }

  /// Quét Bluetooth
  static Future<Map<String, dynamic>> getBluetoothInfo() async {
    // Bài test chỉ QUÉT thiết bị lân cận, không kết nối tới cái nào. Trên
    // Android 12+ việc đó chỉ cần BLUETOOTH_SCAN; BLUETOOTH_CONNECT là quyền
    // để kết nối / đọc tên & danh sách thiết bị đã ghép đôi nên không xin ở
    // đây (xin thừa chỉ tổ hiện thêm một hộp thoại cho kỹ thuật viên bấm).
    final permGranted = await PermissionGate.ensure(
      Platform.isIOS ? Permission.bluetooth : Permission.bluetoothScan,
      name: LocaleKeys.permission_bluetooth_name.trans(),
    );

    final btState = await _resolveAdapterState();

    bool scanOk = false;
    if (btState == BluetoothAdapterState.on) {
      try {
        // Không truyền `timeout` cho startScan: tự dừng sau đúng một lần chờ,
        // tránh chờ gấp đôi.
        await FlutterBluePlus.startScan();
        await Future.delayed(DiagnosticsConstants.bluetoothScanDuration);
        await FlutterBluePlus.stopScan();
        scanOk = true;
      } catch (_) {
        // Thiếu quyền hoặc adapter bận — quét hỏng nhưng adapter vẫn có thể
        // đang bật, nên để `enabled` tự quyết định pass/fail.
      }
    }

    return {
      'enabled': btState == BluetoothAdapterState.on,
      'scanOk': scanOk,
      'permissionGranted': permGranted,
      'state': btState.name,
    };
  }

  /// Đọc trạng thái adapter Bluetooth, chờ qua giai đoạn `unknown`.
  ///
  /// `adapterState.first` KHÔNG dùng được: flutter_blue_plus luôn phát
  /// `unknown` ngay khi có listener, trước lúc CoreBluetooth (iOS) hay
  /// BluetoothAdapter (Android) kịp báo trạng thái thật. Lấy giá trị đầu tiên
  /// là lấy trúng `unknown` đó, nên bài test luôn fail dù Bluetooth đang bật.
  static Future<BluetoothAdapterState> _resolveAdapterState() async {
    final now = FlutterBluePlus.adapterStateNow;
    if (now != BluetoothAdapterState.unknown) return now;

    try {
      return await FlutterBluePlus.adapterState
          .firstWhere((s) => s != BluetoothAdapterState.unknown)
          .timeout(DiagnosticsConstants.bluetoothAdapterStateTimeout);
    } catch (_) {
      return FlutterBluePlus.adapterStateNow;
    }
  }

  /// Trạng thái NFC
  static Future<Map<String, dynamic>> getNfcInfo() async {
    bool available = false;
    try {
      available = await NfcManager.instance.isAvailable();
    } catch (_) {}
    return {'available': available};
  }

  /// Ping các cảm biến (gia tốc kế, con quay hồi chuyển)
  static Future<Map<String, dynamic>> getSensorsPing() async {
    bool accel = false, gyro = false;
    try {
      final s = accelerometerEventStream().listen((_) {});
      await Future.delayed(DiagnosticsConstants.sensorPingDuration);
      await s.cancel();
      accel = true;
    } catch (_) {}
    try {
      final s = gyroscopeEventStream().listen((_) {});
      await Future.delayed(DiagnosticsConstants.sensorPingDuration);
      await s.cancel();
      gyro = true;
    } catch (_) {}
    return {'accelerometer': accel, 'gyroscope': gyro};
  }

  /// Độ chính xác GPS
  static Future<Map<String, dynamic>> getLocationAccuracy() async {
    await PermissionGate.ensure(
      Permission.location,
      name: LocaleKeys.permission_location_name.trans(),
    );
    final perm = await Geolocator.checkPermission();
    final svc = await Geolocator.isLocationServiceEnabled();
    double? accuracy;
    if (svc &&
        (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse)) {
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          accuracy = lastPos.accuracy;
        } else {
          final curPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              timeLimit: Duration(seconds: 4),
            ),
          );
          accuracy = curPos.accuracy;
        }
      } catch (_) {}
    }
    return {'serviceOn': svc, 'accuracyM': accuracy};
  }

  /// Kiểm tra hỗ trợ sinh trắc học
  static Future<Map<String, dynamic>> checkBiometrics() async {
    final la = LocalAuthentication();
    bool can = false, supported = false;
    try {
      can = await la.canCheckBiometrics;
      supported = await la.isDeviceSupported();
    } catch (_) {}
    return {'canCheck': can, 'supported': supported};
  }

  /// Thông tin SIM
  static Future<Map<String, dynamic>> getSimInfo() => DeviceInfoHelper.getSimInfo();

  /// Đọc RAM
  static Future<Map<String, dynamic>> getRamInfo() async {
    try {
      return await DeviceInfoHelper.getRamInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  /// Đọc ROM
  static Future<Map<String, dynamic>> getRomInfo() async {
    try {
      return await DeviceInfoHelper.getRomInfo();
    } catch (_) {
      return const {'freeBytes': null, 'totalBytes': null, 'source': 'error'};
    }
  }

  /// Tai nghe cắm dây có đang kết nối không
  static Future<bool?> isWiredHeadsetPlugged() =>
      _invoke<bool>('isWiredHeadsetPlugged');

  /// Khóa màn hình (PIN / Mật khẩu)
  static Future<bool?> isScreenLocked() => _invoke<bool>('isScreenLocked');

  /// Bút cảm ứng S-Pen (dành riêng cho dòng Samsung Note/Ultra)
  static Future<bool> isSPenSupported() async =>
      (await _invoke<bool>('isSPenSupported')) == true;
}
