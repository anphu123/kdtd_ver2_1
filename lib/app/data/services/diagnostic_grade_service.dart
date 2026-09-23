import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Service tính toán điểm và loại thiết bị sau khi diagnostic.
class DiagnosticGradeService {
  DiagnosticGradeService._();

  /// Tính loại tổng hợp từ kết quả test và khảo sát.
  /// Bất kỳ bài Function Check nào FAILED -> Loại 5.
  /// Ngược lại, lấy theo max(1..5) của Question Check.
  static int finalType({
    required bool hasFunctionCheckFailed,
    required int questionCheckType,
  }) {
    if (hasFunctionCheckFailed) return 5;
    return questionCheckType.clamp(1, 5);
  }

  /// Trả về nhãn "Loại {type}" cho LOẠI THIẾT BỊ TỔNG HỢP (1-5).
  static String labelForType(int type) {
    return LocaleKeys.diagnostic_result_type_label.trans(
      namedArgs: {'type': '$type'},
    );
  }
}
