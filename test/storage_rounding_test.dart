import 'package:flutter_test/flutter_test.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

const _gib = 1024 * 1024 * 1024;

int? _ram(num gib) => DiagnosticsHomeController.roundUpToStandardGb(
  gib * _gib,
  DiagnosticsHomeController.standardRamGb,
);
int? _rom(num gib) => DiagnosticsHomeController.roundUpToStandardGb(
  gib * _gib,
  DiagnosticsHomeController.standardRomGb,
);

void main() {
  group('RAM làm tròn lên từ số máy báo', () {
    test('giá trị OS báo thấp hơn nhãn hộp', () {
      expect(_ram(1.8), 2);
      expect(_ram(2.8), 3);
      expect(_ram(3.7), 4);
      expect(_ram(5.6), 6);
      expect(_ram(7.4), 8);
      expect(_ram(9.4), 10);
      expect(_ram(11.2), 12);
      expect(_ram(15.0), 16);
    });
    test('đúng mốc thì giữ nguyên', () {
      expect(_ram(4), 4);
      expect(_ram(8), 8);
    });
  });

  group('ROM làm tròn lên từ phân vùng /data', () {
    test('không bao giờ ra mốc RAM như 24 GB', () {
      expect(_rom(25), 32);
      expect(_rom(12), 16);
    });
    test('các dung lượng phổ biến', () {
      expect(_rom(52), 64);
      expect(_rom(110), 128);
      expect(_rom(236), 256);
      expect(_rom(470), 512);
      expect(_rom(940), 1024);
    });
    test('vượt bảng mốc thì làm tròn lên số nguyên', () {
      expect(_rom(3000.2), 3001);
    });
  });

  group('không đọc được → null (không bịa số)', () {
    for (final bad in [null, 0, -1, 'abc']) {
      test('$bad', () {
        expect(
          DiagnosticsHomeController.roundUpToStandardGb(
            bad,
            DiagnosticsHomeController.standardRamGb,
          ),
          isNull,
        );
      });
    }
  });
}
