import 'package:flutter/material.dart';

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
  int monthlyInstallment(int topUp, {int months = 12}) {
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
  static List<UpgradeDeviceOption> get defaultOptions => const [
        UpgradeDeviceOption(
          id: 'ip16pm_256',
          name: 'iPhone 16 Pro Max',
          storage: '256GB',
          brand: 'Apple',
          colorName: 'Titan Sa Mạc',
          retailPrice: 34990000,
          subsidyAmount: 2000000,
          tag: 'Hot Nhất',
          icon: Icons.phone_iphone,
          highlights: ['Camera Control', 'Chip A18 Pro', 'Titanium Grade 5'],
        ),
        UpgradeDeviceOption(
          id: 's24u_256',
          name: 'Galaxy S24 Ultra 5G',
          storage: '256GB',
          brand: 'Samsung',
          colorName: 'Xám Titan',
          retailPrice: 29990000,
          subsidyAmount: 2000000,
          tag: 'Trợ Giá 2 Triệu',
          icon: Icons.smartphone,
          highlights: ['Galaxy AI', 'S-Pen tích hợp', 'Camera 200MP'],
        ),
        UpgradeDeviceOption(
          id: 'ip16_128',
          name: 'iPhone 16',
          storage: '128GB',
          brand: 'Apple',
          colorName: 'Xanh Lưu Ly',
          retailPrice: 22490000,
          subsidyAmount: 1500000,
          tag: 'Mới Ra Mắt',
          icon: Icons.phone_iphone,
          highlights: ['Nút Action Button', 'Camera 48MP Fusion', 'Chip A18'],
        ),
        UpgradeDeviceOption(
          id: 'zflip6_256',
          name: 'Galaxy Z Flip6 5G',
          storage: '256GB',
          brand: 'Samsung',
          colorName: 'Xanh Mint',
          retailPrice: 24990000,
          subsidyAmount: 2000000,
          tag: 'Thời Thượng',
          icon: Icons.splitscreen,
          highlights: ['Màn gập bỏ túi', 'FlexCam AI', 'Pin 4.000mAh'],
        ),
        UpgradeDeviceOption(
          id: 'mi14u_512',
          name: 'Xiaomi 14 Ultra',
          storage: '512GB',
          brand: 'Xiaomi',
          colorName: 'Đen Huyền Bí',
          retailPrice: 27990000,
          subsidyAmount: 1500000,
          tag: 'Ống Kính Leica',
          icon: Icons.camera,
          highlights: ['Ống kính Leica Summilux', 'Snapdragon 8 Gen 3', 'Sạc 90W'],
        ),
      ];
}
