import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/diagnostics/model/profile_manager.dart';
import 'package:kdtd_ver2_1/diagnostics/model/rule_evaluator.dart';
import 'package:kdtd_ver2_1/diagnostics/model/diag_environment.dart';

/// Example: How to use the Rule Evaluation System
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Example 1: Load and use profiles
  await exampleLoadProfile();

  // Example 2: Evaluate a test result
  await exampleEvaluateTest();

  // Example 3: Check brand quirks
  exampleBrandQuirks();
}

/// Example 1: Loading Device Profiles
Future<void> exampleLoadProfile() async {
  print('\n📱 Example 1: Loading Device Profiles\n');

  final profileManager = await ProfileManager.getInstance();

  // Get profile for Samsung S21 Ultra
  final s21Ultra = profileManager.getProfile('SM-G998B', 'Samsung');
  print('Profile: ${s21Ultra.name}');
  print('Requires: ${s21Ultra.require}');
  print('S-Pen: ${s21Ultra.sPen}');
  print('Bio: ${s21Ultra.bio}');

  // Get profile for Xiaomi 12
  final xiaomi12 = profileManager.getProfile('2201123G', 'Xiaomi');
  print('\nProfile: ${xiaomi12.name}');
  print('Requires: ${xiaomi12.require}');

  // Get default profile for unknown device
  final unknown = profileManager.getProfile('UNKNOWN_MODEL', 'UnknownBrand');
  print('\nProfile: ${unknown.name}');
}

/// Example 2: Evaluating Test Results
Future<void> exampleEvaluateTest() async {
  print('\n🔍 Example 2: Evaluating Test Results\n');

  // Setup
  final profileManager = await ProfileManager.getInstance();
  final profile = profileManager.getProfile('SM-G998B', 'Samsung');

  final environment = DiagEnvironment(
    brand: 'Samsung',
    platform: 'android',
    locationServiceOn: true,
    grantedPerms: {'location', 'camera', 'microphone'},
    deniedPerms: {},
    sensors: {'accelerometer': true, 'gyroscope': true},
  );

  final evaluator = await RuleEvaluator.create(
    profile: profile,
    environment: environment,
  );

  // Test WiFi - PASS
  final wifiPayload = {
    'connected': true,
    'ssid': 'MyHomeWiFi',
  };
  final wifiResult = evaluator.evaluate('wifi', wifiPayload);
  final wifiReason = evaluator.getReason('wifi', wifiPayload, wifiResult);
  print('WiFi Test: $wifiResult');
  print('Reason: $wifiReason\n');

  // Test Mobile - FAIL (weak signal)
  final mobilePayload = {
    'connected': true,
    'dbm': -125, // Too weak
    'radio': 'LTE',
  };
  final mobileResult = evaluator.evaluate('mobile', mobilePayload);
  final mobileReason = evaluator.getReason('mobile', mobilePayload, mobileResult);
  print('Mobile Test: $mobileResult');
  print('Reason: $mobileReason\n');

  // Test GPS - SKIP (location off)
  final gpsEnvironment = environment.copyWith(locationServiceOn: false);
  final gpsEvaluator = await RuleEvaluator.create(
    profile: profile,
    environment: gpsEnvironment,
  );
  final gpsPayload = {
    'serviceOn': false,
    'accuracyM': null,
  };
  final gpsResult = gpsEvaluator.evaluate('gps', gpsPayload);
  final gpsReason = gpsEvaluator.getReason('gps', gpsPayload, gpsResult);
  print('GPS Test: $gpsResult');
  print('Reason: $gpsReason\n');

  // Test S-Pen - PASS (required for S21 Ultra)
  final spenPayload = true;
  final spenResult = evaluator.evaluate('spen', {'detected': spenPayload});
  print('S-Pen Test: $spenResult');
  print('Required by profile: ${profile.sPen}');

  // Test Touch - PASS
  final touchPayload = {
    'passRatio': 0.99,
    'deadZones': [],
  };
  final touchResult = evaluator.evaluate('touch', touchPayload);
  final touchReason = evaluator.getReason('touch', touchPayload, touchResult);
  print('\nTouch Test: $touchResult');
  print('Reason: $touchReason');
}

/// Example 3: Checking Brand Quirks
void exampleBrandQuirks() async {
  print('\n🔧 Example 3: Brand Quirks\n');

  final profileManager = await ProfileManager.getInstance();

  // Xiaomi quirks
  print('Xiaomi (MIUI):');
  print('  WiFi requires location: ${profileManager.requiresLocationForWifi('xiaomi')}');
  print('  BT requires location: ${profileManager.requiresLocationForBluetooth('xiaomi')}');

  // Samsung quirks
  print('\nSamsung:');
  print('  WiFi requires location: ${profileManager.requiresLocationForWifi('samsung')}');
  print('  BT requires location: ${profileManager.requiresLocationForBluetooth('samsung')}');

  // OPPO quirks
  print('\nOPPO (ColorOS):');
  print('  WiFi requires location: ${profileManager.requiresLocationForWifi('oppo')}');
  print('  BT requires location: ${profileManager.requiresLocationForBluetooth('oppo')}');

  // Generic quirks
  final xiaomiQuirks = profileManager.getBrandQuirks('xiaomi');
  print('\nAll Xiaomi quirks: $xiaomiQuirks');
}

/// Example 4: Complete Test Flow
class ExampleDiagnosticsFlow {
  Future<void> runDiagnostics() async {
    print('\n🚀 Example 4: Complete Diagnostics Flow\n');

    // 1. Get device info
    final deviceModel = 'SM-G998B'; // Samsung S21 Ultra
    final deviceBrand = 'Samsung';

    // 2. Load profile
    final profileManager = await ProfileManager.getInstance();
    final profile = profileManager.getProfile(deviceModel, deviceBrand);
    print('Testing device: $deviceBrand $deviceModel');
    print('Profile loaded: ${profile.name}');

    // 3. Build environment
    final environment = DiagEnvironment(
      brand: deviceBrand,
      platform: 'android',
      locationServiceOn: true,
      grantedPerms: {'location', 'camera', 'microphone', 'bluetoothScan'},
      deniedPerms: {},
      sensors: {'accelerometer': true, 'gyroscope': true},
    );

    // 4. Create evaluator
    final evaluator = await RuleEvaluator.create(
      profile: profile,
      environment: environment,
    );

    // 5. Run tests (simplified)
    final tests = [
      {'code': 'wifi', 'payload': {'connected': true, 'ssid': 'TestNet'}},
      {'code': 'mobile', 'payload': {'connected': true, 'dbm': -75, 'radio': 'LTE'}},
      {'code': 'gps', 'payload': {'serviceOn': true, 'accuracyM': 12.5}},
      {'code': 'nfc', 'payload': {'available': true}},
      {'code': 'spen', 'payload': {'detected': true}},
    ];

    var passed = 0;
    var failed = 0;
    var skipped = 0;

    print('\nRunning tests...\n');
    for (final test in tests) {
      final code = test['code'] as String;
      final payload = test['payload'] as Map<String, dynamic>;

      final result = evaluator.evaluate(code, payload);
      final reason = evaluator.getReason(code, payload, result);

      print('[$code] $result - $reason');

      switch (result) {
        case EvalResult.pass:
          passed++;
          break;
        case EvalResult.fail:
          failed++;
          break;
        case EvalResult.skip:
          skipped++;
          break;
      }
    }

    // 6. Calculate score
    final total = tests.length;
    final score = (passed * 100 / total).round();
    print('\n📊 Results:');
    print('   Passed: $passed');
    print('   Failed: $failed');
    print('   Skipped: $skipped');
    print('   Score: $score/100');
  }
}

