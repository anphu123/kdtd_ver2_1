import 'package:flutter_test/flutter_test.dart';
import 'package:kdtd_ver2_1/app/core/constants/rule_evaluator_constants.dart';
import 'package:kdtd_ver2_1/app/data/model/device_profile.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_environment.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_thresholds.dart';
import 'package:kdtd_ver2_1/app/data/services/rule_evaluator.dart';

void main() {
  late DiagThresholds thresholds;
  late DeviceProfile profile;
  late DiagEnvironment environment;
  late RuleEvaluator evaluator;

  setUp(() {
    thresholds = DiagThresholds.defaults();
    profile = const DeviceProfile(name: 'Test Device');
    environment = const DiagEnvironment();
    evaluator = RuleEvaluator(
      thresholds: thresholds,
      profile: profile,
      environment: environment,
    );
  });

  group('RuleEvaluator - battery', () {
    test(
      'level nằm trong [minBatteryLevel, maxBatteryLevel] -> EvalResult.pass',
      () {
        // Giá trị tại ngưỡng dưới minBatteryLevel
        expect(
          evaluator.evaluate('battery', {
            'level': RuleEvaluatorConstants.minBatteryLevel,
          }),
          EvalResult.pass,
        );

        // Giá trị ở khoảng giữa
        final midLevel =
            (RuleEvaluatorConstants.minBatteryLevel +
                RuleEvaluatorConstants.maxBatteryLevel) /
            2;
        expect(
          evaluator.evaluate('battery', {'level': midLevel}),
          EvalResult.pass,
        );

        // Giá trị tại ngưỡng trên maxBatteryLevel
        expect(
          evaluator.evaluate('battery', {
            'level': RuleEvaluatorConstants.maxBatteryLevel,
          }),
          EvalResult.pass,
        );
      },
    );

    test(
      'level ngoài khoảng [minBatteryLevel, maxBatteryLevel] (cả dưới min và trên max) -> EvalResult.fail',
      () {
        // Dưới ngưỡng tối thiểu minBatteryLevel
        expect(
          evaluator.evaluate('battery', {
            'level': RuleEvaluatorConstants.minBatteryLevel - 1,
          }),
          EvalResult.fail,
        );

        // Trên ngưỡng tối đa maxBatteryLevel
        expect(
          evaluator.evaluate('battery', {
            'level': RuleEvaluatorConstants.maxBatteryLevel + 1,
          }),
          EvalResult.fail,
        );
      },
    );

    test('level không phải số (ví dụ String, null, bool) -> EvalResult.fail', () {
      // Kiểu String
      expect(
        evaluator.evaluate('battery', {'level': '80'}),
        EvalResult.fail,
      );

      // Kiểu null
      expect(
        evaluator.evaluate('battery', {'level': null}),
        EvalResult.fail,
      );

      // Không có trường level
      expect(
        evaluator.evaluate('battery', <String, dynamic>{}),
        EvalResult.fail,
      );

      // Kiểu boolean
      expect(
        evaluator.evaluate('battery', {'level': true}),
        EvalResult.fail,
      );
    });
  });

  group('RuleEvaluator - wifi', () {
    test('enabled=false và connected=false -> EvalResult.fail', () {
      expect(
        evaluator.evaluate('wifi', {
          'enabled': false,
          'connected': false,
        }),
        EvalResult.fail,
      );
    });

    test('enabled=true -> EvalResult.pass', () {
      // enabled=true, connected=false
      expect(
        evaluator.evaluate('wifi', {
          'enabled': true,
          'connected': false,
        }),
        EvalResult.pass,
      );

      // enabled=true, connected=true
      expect(
        evaluator.evaluate('wifi', {
          'enabled': true,
          'connected': true,
        }),
        EvalResult.pass,
      );
    });
  });

  group('RuleEvaluator - mobile', () {
    test('connected=false -> EvalResult.skip', () {
      expect(
        evaluator.evaluate('mobile', {
          'connected': false,
        }),
        EvalResult.skip,
      );

      // connected=false kể cả khi có tín hiệu dbm và radio
      expect(
        evaluator.evaluate('mobile', {
          'connected': false,
          'dbm': -80,
          'radio': 'LTE',
        }),
        EvalResult.skip,
      );
    });

    test(
      'dbm nằm trong [thresholds.mobile.dbmMin, thresholds.mobile.dbmMax] với radio hợp lệ (>= minAcceptableRadioGeneration) -> EvalResult.pass',
      () {
        // Tại ngưỡng dưới dbmMin với radio LTE (4G >= minAcceptableRadioGeneration)
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': thresholds.mobile.dbmMin,
            'radio': 'LTE',
          }),
          EvalResult.pass,
        );

        // Giá trị giữa khoảng dbm
        final midDbm =
            (thresholds.mobile.dbmMin + thresholds.mobile.dbmMax) ~/ 2;
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': midDbm,
            'radio': 'LTE',
          }),
          EvalResult.pass,
        );

        // Tại ngưỡng trên dbmMax
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': thresholds.mobile.dbmMax,
            'radio': 'LTE',
          }),
          EvalResult.pass,
        );

        // Radio 3G (UMTS >= 3) trong ngưỡng dbm
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': midDbm,
            'radio': 'UMTS',
          }),
          EvalResult.pass,
        );

        // Radio 5G (NR >= 3) trong ngưỡng dbm
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': midDbm,
            'radio': 'NR',
          }),
          EvalResult.pass,
        );
      },
    );

    test('dbm ngoài khoảng [thresholds.mobile.dbmMin, thresholds.mobile.dbmMax] -> EvalResult.fail', () {
      // Dưới ngưỡng dbmMin
      expect(
        evaluator.evaluate('mobile', {
          'connected': true,
          'dbm': thresholds.mobile.dbmMin - 1,
          'radio': 'LTE',
        }),
        EvalResult.fail,
      );

      // Trên ngưỡng dbmMax
      expect(
        evaluator.evaluate('mobile', {
          'connected': true,
          'dbm': thresholds.mobile.dbmMax + 1,
          'radio': 'LTE',
        }),
        EvalResult.fail,
      );
    });

    test(
      'radio dưới thế hệ tối thiểu (< minAcceptableRadioGeneration, ví dụ 2G GSM) -> EvalResult.fail',
      () {
        final midDbm =
            (thresholds.mobile.dbmMin + thresholds.mobile.dbmMax) ~/ 2;
        // GSM là 2G (gen 2 < minAcceptableRadioGeneration 3) -> fail
        expect(
          evaluator.evaluate('mobile', {
            'connected': true,
            'dbm': midDbm,
            'radio': 'GSM',
          }),
          EvalResult.fail,
        );
      },
    );

    test('dbm không phải số hoặc null', () {
      // dbm = null -> EvalResult.skip (theo logic _evalMobile)
      expect(
        evaluator.evaluate('mobile', {
          'connected': true,
          'dbm': null,
          'radio': 'LTE',
        }),
        EvalResult.skip,
      );

      // dbm không phải num -> EvalResult.fail
      expect(
        evaluator.evaluate('mobile', {
          'connected': true,
          'dbm': 'invalid',
          'radio': 'LTE',
        }),
        EvalResult.fail,
      );
    });
  });
}
