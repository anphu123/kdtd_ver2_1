import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import 'package:kdtd_ver2_1/app/core/constants/upgrade_device_constants.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Dòng máy mới gợi ý để khách hàng lên đời
class UpgradeDeviceOption {
  final String id;
  final String name;
  final String storage;
  final String brand;
  final String colorName;
  final int retailPrice;
  final int subsidyAmount; // Số tiền trợ giá độc quyền khi thu cũ lên đời
  final String tag;
  final IconData icon;
  final List<String> highlights;

  const UpgradeDeviceOption({
    required this.id,
    required this.name,
    required this.storage,
    required this.brand,
    required this.colorName,
    required this.retailPrice,
    required this.subsidyAmount,
    required this.tag,
    required this.icon,
    this.highlights = const [],
  });

  /// Tính số tiền bù thực tế sau khi trừ giá thu máy cũ và tiền trợ giá
  int calculateTopUp(int tradeInValue) {
    final topUp = retailPrice - tradeInValue - subsidyAmount;
    return topUp > 0 ? topUp : 0;
  }

  /// Tính trả góp dự kiến 0% lãi suất (12 tháng)
  int monthlyInstallment(
    int topUp, {
    int months = UpgradeDeviceConstants.defaultInstallmentMonths,
  }) {
    if (topUp <= 0) return 0;
    return (topUp / months).round();
  }

  /// Định dạng tiền tệ
  static String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  String get formattedRetailPrice => formatCurrency(retailPrice);
  String get formattedSubsidy => formatCurrency(subsidyAmount);

  /// Danh sách máy mới đề xuất hot nhất thị trường hiện nay
  static List<UpgradeDeviceOption> get defaultOptions => [
    UpgradeDeviceOption(
      id: 'ip16pm_256',
      name: 'iPhone 16 Pro Max',
      storage: '256GB',
      brand: 'Apple',
      colorName: LocaleKeys.upgrade_device_option_ip16pm_256_color.trans(),
      retailPrice: 34990000,
      subsidyAmount: 2000000,
      tag: LocaleKeys.upgrade_device_option_ip16pm_256_tag.trans(),
      icon: Icons.phone_iphone,
      highlights: [
        LocaleKeys.upgrade_device_option_ip16pm_256_highlight_1.trans(),
        LocaleKeys.upgrade_device_option_ip16pm_256_highlight_2.trans(),
        LocaleKeys.upgrade_device_option_ip16pm_256_highlight_3.trans(),
      ],
    ),
    UpgradeDeviceOption(
      id: 's24u_256',
      name: 'Galaxy S24 Ultra 5G',
      storage: '256GB',
      brand: 'Samsung',
      colorName: LocaleKeys.upgrade_device_option_s24u_256_color.trans(),
      retailPrice: 29990000,
      subsidyAmount: 2000000,
      tag: LocaleKeys.upgrade_device_option_s24u_256_tag.trans(),
      icon: Icons.smartphone,
      highlights: [
        LocaleKeys.upgrade_device_option_s24u_256_highlight_1.trans(),
        LocaleKeys.upgrade_device_option_s24u_256_highlight_2.trans(),
        LocaleKeys.upgrade_device_option_s24u_256_highlight_3.trans(),
      ],
    ),
    UpgradeDeviceOption(
      id: 'ip16_128',
      name: 'iPhone 16',
      storage: '128GB',
      brand: 'Apple',
      colorName: LocaleKeys.upgrade_device_option_ip16_128_color.trans(),
      retailPrice: 22490000,
      subsidyAmount: 1500000,
      tag: LocaleKeys.upgrade_device_option_ip16_128_tag.trans(),
      icon: Icons.phone_iphone,
      highlights: [
        LocaleKeys.upgrade_device_option_ip16_128_highlight_1.trans(),
        LocaleKeys.upgrade_device_option_ip16_128_highlight_2.trans(),
        LocaleKeys.upgrade_device_option_ip16_128_highlight_3.trans(),
      ],
    ),
    UpgradeDeviceOption(
      id: 'zflip6_256',
      name: 'Galaxy Z Flip6 5G',
      storage: '256GB',
      brand: 'Samsung',
      colorName: LocaleKeys.upgrade_device_option_zflip6_256_color.trans(),
      retailPrice: 24990000,
      subsidyAmount: 2000000,
      tag: LocaleKeys.upgrade_device_option_zflip6_256_tag.trans(),
      icon: Icons.splitscreen,
      highlights: [
        LocaleKeys.upgrade_device_option_zflip6_256_highlight_1.trans(),
        LocaleKeys.upgrade_device_option_zflip6_256_highlight_2.trans(),
        LocaleKeys.upgrade_device_option_zflip6_256_highlight_3.trans(),
      ],
    ),
    UpgradeDeviceOption(
      id: 'mi14u_512',
      name: 'Xiaomi 14 Ultra',
      storage: '512GB',
      brand: 'Xiaomi',
      colorName: LocaleKeys.upgrade_device_option_mi14u_512_color.trans(),
      retailPrice: 27990000,
      subsidyAmount: 1500000,
      tag: LocaleKeys.upgrade_device_option_mi14u_512_tag.trans(),
      icon: Icons.camera,
      highlights: [
        LocaleKeys.upgrade_device_option_mi14u_512_highlight_1.trans(),
        LocaleKeys.upgrade_device_option_mi14u_512_highlight_2.trans(),
        LocaleKeys.upgrade_device_option_mi14u_512_highlight_3.trans(),
      ],
    ),
  ];
}
