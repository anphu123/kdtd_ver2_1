import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/excel_import_service.dart';

class AdminDataController extends GetxController {
  // Observable lists
  final devices = <DeviceModel>[].obs;
  final allPrices = <MonthlyPrice>[].obs;

  // Computed
  List<MonthlyPrice> get currentMonthPrices {
    final currentMonth = ExcelImportService.getCurrentMonth();
    return allPrices.where((p) => p.month == currentMonth).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load data from SharedPreferences
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load devices
      final devicesJson = prefs.getString('devices');
      if (devicesJson != null) {
        final List<dynamic> decoded = json.decode(devicesJson);
        devices.value = decoded.map((d) => DeviceModel.fromJson(d)).toList();
      }

      // Load prices
      final pricesJson = prefs.getString('prices');
      if (pricesJson != null) {
        final List<dynamic> decoded = json.decode(pricesJson);
        allPrices.value = decoded.map((p) => MonthlyPrice.fromJson(p)).toList();
      }

      print(
        '✓ Loaded ${devices.length} devices and ${allPrices.length} prices',
      );
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  /// Save data to SharedPreferences
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save devices
      final devicesJson = json.encode(devices.map((d) => d.toJson()).toList());
      await prefs.setString('devices', devicesJson);

      // Save prices
      final pricesJson = json.encode(allPrices.map((p) => p.toJson()).toList());
      await prefs.setString('prices', pricesJson);

      print('✓ Saved ${devices.length} devices and ${allPrices.length} prices');
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Import devices from TC_list
  Future<void> importDevices(List<DeviceModel> newDevices) async {
    devices.value = newDevices;
    await saveData();
  }

  /// Import prices from TradeIn file
  Future<void> importPrices(List<MonthlyPrice> newPrices) async {
    allPrices.value = newPrices;
    await saveData();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    devices.clear();
    allPrices.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('devices');
    await prefs.remove('prices');

    Get.snackbar(
      'Đã xóa',
      'Tất cả dữ liệu đã được xóa',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Get device by model name
  DeviceModel? getDevice(String modelName) {
    try {
      return devices.firstWhere((d) => d.modelName == modelName);
    } catch (e) {
      return null;
    }
  }

  /// Get price for model, month, and grade
  int? getPrice(String modelName, String month, String grade) {
    return ExcelImportService.getPriceForMonth(
      allPrices,
      modelName,
      month,
      grade,
    );
  }

  /// Get current month price for model and score
  int? getCurrentPrice(String modelName, int score) {
    final grade = ExcelImportService.scoreToGrade(score);
    final month = ExcelImportService.getCurrentMonth();
    return getPrice(modelName, month, grade);
  }
}
