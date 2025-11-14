import 'dart:io';
import 'package:excel/excel.dart';

/// Service để import data từ Excel files
class ExcelImportService {
  /// Parse TC_list Excel file
  static Future<List<DeviceModel>> parseTCList(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final devices = <DeviceModel>[];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // Skip header row (row 0)
        for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          final row = sheet.rows[rowIndex];

          try {
            // Assuming columns: Model | Marketing Name | Brand | Base Price | RAM | ROM | Year
            final model = _getCellValue(row, 0);
            final marketingName = _getCellValue(row, 1);
            final brand = _getCellValue(row, 2);
            final basePrice = _getCellValueAsInt(row, 3);
            final ram = _getCellValueAsInt(row, 4);
            final rom = _getCellValueAsInt(row, 5);
            final year = _getCellValueAsInt(row, 6);

            if (model.isEmpty) continue;

            devices.add(
              DeviceModel(
                modelName: model,
                marketingName: marketingName,
                brand: brand,
                basePrice: basePrice,
                ramGb: ram,
                romGb: rom,
                releaseYear: year,
              ),
            );
          } catch (e) {
            print('Error parsing row $rowIndex: $e');
            continue;
          }
        }
      }

      return devices;
    } catch (e) {
      print('Error parsing TC_list: $e');
      return [];
    }
  }

  /// Parse Data_2Hand_Tradein Excel file (giá theo tháng)
  static Future<List<MonthlyPrice>> parseTradeInPrices(String filePath) async {
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final prices = <MonthlyPrice>[];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // Skip header row
        for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          final row = sheet.rows[rowIndex];

          try {
            // Assuming columns: Model | Month | Grade A | Grade B | Grade C | Grade D
            final model = _getCellValue(row, 0);
            final month = _getCellValue(
              row,
              1,
            ); // Format: "T9/2025" or "09/2025"
            final gradeA = _getCellValueAsInt(row, 2);
            final gradeB = _getCellValueAsInt(row, 3);
            final gradeC = _getCellValueAsInt(row, 4);
            final gradeD = _getCellValueAsInt(row, 5);

            if (model.isEmpty) continue;

            prices.add(
              MonthlyPrice(
                modelName: model,
                month: month,
                gradeAPriceVnd: gradeA,
                gradeBPriceVnd: gradeB,
                gradeCPriceVnd: gradeC,
                gradeDPriceVnd: gradeD,
              ),
            );
          } catch (e) {
            print('Error parsing row $rowIndex: $e');
            continue;
          }
        }
      }

      return prices;
    } catch (e) {
      print('Error parsing TradeIn prices: $e');
      return [];
    }
  }

  /// Helper: Get cell value as string
  static String _getCellValue(List<Data?> row, int columnIndex) {
    if (columnIndex >= row.length) return '';
    final cell = row[columnIndex];
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }

  /// Helper: Get cell value as int
  static int _getCellValueAsInt(List<Data?> row, int columnIndex) {
    final value = _getCellValue(row, columnIndex);
    if (value.isEmpty) return 0;

    // Remove non-numeric characters (except digits and .)
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  /// Get price for specific model and month
  static int? getPriceForMonth(
    List<MonthlyPrice> prices,
    String modelName,
    String month,
    String grade,
  ) {
    final price = prices.firstWhere(
      (p) => p.modelName == modelName && p.month == month,
      orElse:
          () => MonthlyPrice(
            modelName: '',
            month: '',
            gradeAPriceVnd: 0,
            gradeBPriceVnd: 0,
            gradeCPriceVnd: 0,
            gradeDPriceVnd: 0,
          ),
    );

    switch (grade.toUpperCase()) {
      case 'A':
        return price.gradeAPriceVnd;
      case 'B':
        return price.gradeBPriceVnd;
      case 'C':
        return price.gradeCPriceVnd;
      case 'D':
        return price.gradeDPriceVnd;
      default:
        return null;
    }
  }

  /// Convert score to grade
  static String scoreToGrade(int score) {
    if (score >= 90) return 'A'; // Xuất sắc
    if (score >= 80) return 'B'; // Tốt
    if (score >= 70) return 'C'; // Khá
    return 'D'; // Trung bình/Yếu
  }

  /// Get current month string (format: "T9/2025")
  static String getCurrentMonth() {
    final now = DateTime.now();
    return 'T${now.month}/${now.year}';
  }
}

/// Model cho thiết bị từ TC_list
class DeviceModel {
  final String modelName;
  final String marketingName;
  final String brand;
  final int basePrice;
  final int ramGb;
  final int romGb;
  final int releaseYear;

  DeviceModel({
    required this.modelName,
    required this.marketingName,
    required this.brand,
    required this.basePrice,
    required this.ramGb,
    required this.romGb,
    required this.releaseYear,
  });

  Map<String, dynamic> toJson() => {
    'modelName': modelName,
    'marketingName': marketingName,
    'brand': brand,
    'basePrice': basePrice,
    'ramGb': ramGb,
    'romGb': romGb,
    'releaseYear': releaseYear,
  };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    modelName: json['modelName'] as String,
    marketingName: json['marketingName'] as String,
    brand: json['brand'] as String,
    basePrice: json['basePrice'] as int,
    ramGb: json['ramGb'] as int,
    romGb: json['romGb'] as int,
    releaseYear: json['releaseYear'] as int,
  );
}

/// Model cho giá theo tháng
class MonthlyPrice {
  final String modelName;
  final String month; // Format: "T9/2025"
  final int gradeAPriceVnd; // Grade A (90-100 điểm)
  final int gradeBPriceVnd; // Grade B (80-89 điểm)
  final int gradeCPriceVnd; // Grade C (70-79 điểm)
  final int gradeDPriceVnd; // Grade D (<70 điểm)

  MonthlyPrice({
    required this.modelName,
    required this.month,
    required this.gradeAPriceVnd,
    required this.gradeBPriceVnd,
    required this.gradeCPriceVnd,
    required this.gradeDPriceVnd,
  });

  Map<String, dynamic> toJson() => {
    'modelName': modelName,
    'month': month,
    'gradeA': gradeAPriceVnd,
    'gradeB': gradeBPriceVnd,
    'gradeC': gradeCPriceVnd,
    'gradeD': gradeDPriceVnd,
  };

  factory MonthlyPrice.fromJson(Map<String, dynamic> json) => MonthlyPrice(
    modelName: json['modelName'] as String,
    month: json['month'] as String,
    gradeAPriceVnd: json['gradeA'] as int,
    gradeBPriceVnd: json['gradeB'] as int,
    gradeCPriceVnd: json['gradeC'] as int,
    gradeDPriceVnd: json['gradeD'] as int,
  );
}
