/// Device Name Mapper
/// Maps device model codes to marketing names
class DeviceNameMapper {
  /// Get marketing name from model code
  static String getMarketingName(String model, String brand) {
    final modelUpper = model.toUpperCase();
    final brandUpper = brand.toUpperCase();

    // Samsung devices
    if (brandUpper.contains('SAMSUNG')) {
      return _getSamsungName(modelUpper);
    }

    // Xiaomi devices
    if (brandUpper.contains('XIAOMI')) {
      return _getXiaomiName(modelUpper);
    }

    // Oppo devices
    if (brandUpper.contains('OPPO')) {
      return _getOppoName(modelUpper);
    }

    // Vivo devices
    if (brandUpper.contains('VIVO')) {
      return _getVivoName(modelUpper);
    }

    // Google Pixel
    if (brandUpper.contains('GOOGLE')) {
      return _getPixelName(modelUpper);
    }

    // Apple (iOS)
    if (brandUpper.contains('APPLE')) {
      return 'iPhone $model';
    }

    // Default: return brand + model
    return '$brand $model';
  }

  static String _getSamsungName(String model) {
    // Galaxy S Series
    if (model.contains('SM-G991')) return 'Galaxy S21 5G';
    if (model.contains('SM-G996')) return 'Galaxy S21+';
    if (model.contains('SM-G998')) return 'Galaxy S21 Ultra';
    if (model.contains('SM-G990')) return 'Galaxy S21 FE';
    if (model.contains('SM-S901')) return 'Galaxy S22';
    if (model.contains('SM-S906')) return 'Galaxy S22+';
    if (model.contains('SM-S908')) return 'Galaxy S22 Ultra';
    if (model.contains('SM-S911')) return 'Galaxy S23';
    if (model.contains('SM-S916')) return 'Galaxy S23+';
    if (model.contains('SM-S918')) return 'Galaxy S23 Ultra';
    if (model.contains('SM-S921')) return 'Galaxy S24';
    if (model.contains('SM-S926')) return 'Galaxy S24+';
    if (model.contains('SM-S928')) return 'Galaxy S24 Ultra';

    // Galaxy A Series
    if (model.contains('SM-A536')) return 'Galaxy A53 5G';
    if (model.contains('SM-A546')) return 'Galaxy A54 5G';
    if (model.contains('SM-A556')) return 'Galaxy A55 5G';
    if (model.contains('SM-A336')) return 'Galaxy A33 5G';
    if (model.contains('SM-A346')) return 'Galaxy A34 5G';
    if (model.contains('SM-A356')) return 'Galaxy A35 5G';
    if (model.contains('SM-A736')) return 'Galaxy A73 5G';
    if (model.contains('SM-A146')) return 'Galaxy A14';
    if (model.contains('SM-A156')) return 'Galaxy A15';
    if (model.contains('SM-A256')) return 'Galaxy A25';
    if (model.contains('SM-A056')) return 'Galaxy A05';

    // Galaxy Z Series (Foldable)
    if (model.contains('SM-F936')) return 'Galaxy Z Fold4';
    if (model.contains('SM-F946')) return 'Galaxy Z Fold5';
    if (model.contains('SM-F956')) return 'Galaxy Z Fold6';
    if (model.contains('SM-F731')) return 'Galaxy Z Flip5';
    if (model.contains('SM-F741')) return 'Galaxy Z Flip6';

    // Galaxy Note Series
    if (model.contains('SM-N986')) return 'Galaxy Note20 Ultra';
    if (model.contains('SM-N981')) return 'Galaxy Note20';

    return 'Samsung $model';
  }

  static String _getXiaomiName(String model) {
    // Xiaomi flagship
    if (model.contains('2201123G') || model.contains('2201123C')) {
      return 'Xiaomi 12';
    }
    if (model.contains('2206123SC')) return 'Xiaomi 12 Pro';
    if (model.contains('2211133C')) return 'Xiaomi 13';
    if (model.contains('2210132C')) return 'Xiaomi 13 Pro';
    if (model.contains('23013RK75C')) return 'Xiaomi 14';
    if (model.contains('23116PN5BC')) return 'Xiaomi 14 Pro';

    // Redmi Note Series
    if (model.contains('M2012K11AG')) return 'Redmi Note 10 Pro';
    if (model.contains('21091116AG')) return 'Redmi Note 11';
    if (model.contains('22101316G')) return 'Redmi Note 12';
    if (model.contains('23021RAAEG')) return 'Redmi Note 13';

    // POCO Series
    if (model.contains('M2101K6G')) return 'POCO X3 Pro';
    if (model.contains('22101320G')) return 'POCO X5 Pro';

    return 'Xiaomi $model';
  }

  static String _getOppoName(String model) {
    if (model.contains('CPH2451')) return 'Oppo Find X5 Pro';
    if (model.contains('CPH2525')) return 'Oppo Find X6 Pro';
    if (model.contains('CPH2437')) return 'Oppo Reno8 Pro';
    if (model.contains('CPH2481')) return 'Oppo Reno9 Pro';
    if (model.contains('CPH2531')) return 'Oppo Reno10 Pro';
    if (model.contains('CPH2415')) return 'Oppo A77';
    if (model.contains('CPH2565')) return 'Oppo A78';

    return 'Oppo $model';
  }

  static String _getVivoName(String model) {
    if (model.contains('V2227')) return 'Vivo X90 Pro';
    if (model.contains('V2250')) return 'Vivo X80 Pro';
    if (model.contains('V2231')) return 'Vivo V27 Pro';
    if (model.contains('V2254')) return 'Vivo V25 Pro';
    if (model.contains('V2207')) return 'Vivo Y35';

    return 'Vivo $model';
  }

  static String _getPixelName(String model) {
    if (model.contains('PIXEL 8 PRO')) return 'Pixel 8 Pro';
    if (model.contains('PIXEL 8')) return 'Pixel 8';
    if (model.contains('PIXEL 7 PRO')) return 'Pixel 7 Pro';
    if (model.contains('PIXEL 7')) return 'Pixel 7';
    if (model.contains('PIXEL 6 PRO')) return 'Pixel 6 Pro';
    if (model.contains('PIXEL 6')) return 'Pixel 6';

    return model;
  }
}
