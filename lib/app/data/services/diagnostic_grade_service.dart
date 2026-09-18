import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/core/constants/diagnostic_grade_constants.dart';

/// Xếp hạng thiết bị (A/B/C/D) theo điểm số kiểm định.
/// Gộp logic trùng lặp từ diagnostic_result_page và failed_tests_warning_page
/// (trước đây mỗi trang tự tính với ngưỡng khác nhau, gây lệch hạng hiển thị).
class DiagnosticGradeService {
  DiagnosticGradeService._();

  /// Trả về chữ cái xếp hạng (A/B/C/D) từ điểm số 0-100.
  static String letterFromScore(int score) {
    if (score >= DiagnosticGradeConstants.gradeAMinScore) return 'A';
    if (score >= DiagnosticGradeConstants.gradeBMinScore) return 'B';
    if (score >= DiagnosticGradeConstants.gradeCMinScore) return 'C';
    return 'D';
  }

  /// Trả về nhãn đã dịch (vd "Hạng A") từ điểm số 0-100.
  static String labelFromScore(int score) {
    switch (letterFromScore(score)) {
      case 'A':
        return LocaleKeys.diagnostic_result_grade_a.trans();
      case 'B':
        return LocaleKeys.diagnostic_result_grade_b.trans();
      case 'C':
        return LocaleKeys.diagnostic_result_grade_c.trans();
      default:
        return LocaleKeys.diagnostic_result_grade_d.trans();
    }
  }
}
