import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Device Info Section - Displays device information and progress
class DeviceInfoSection extends StatelessWidget {
  const DeviceInfoSection({
    super.key,
    required this.modelName,
    required this.brand,
    required this.manufacturer,
    required this.platform,
    required this.progress,
    required this.completed,
    required this.total,
    this.ramInfo,
    this.romInfo,
    this.origin,
    this.marketingName,
  });

  final String modelName;
  final String brand;
  final String manufacturer;
  final String platform;
  final double progress;
  final int completed;
  final int total;
  final Map<String, dynamic>? ramInfo;
  final Map<String, dynamic>? romInfo;
  final String? origin;
  final String? marketingName;

  int? _toGiB(dynamic v) {
    if (v is! num) return null;
    const giB = 1024 * 1024 * 1024;
    final gb = v.toDouble() / giB;

    // Làm tròn theo các mức chuẩn: 2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512
    const standardSizes = [2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512, 1024];

    // Tìm mức gần nhất
    int closest = standardSizes[0];
    double minDiff = (gb - closest).abs();

    for (final size in standardSizes) {
      final diff = (gb - size).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }

    return closest;
  }

  @override
  Widget build(BuildContext context) {
    final ramTotal = _toGiB(ramInfo?['totalBytes']);
    final romTotal = _toGiB(romInfo?['totalBytes']);

    final displayName = marketingName != null &&
            marketingName!.isNotEmpty &&
            marketingName != '-'
        ? marketingName!
        : (modelName.isNotEmpty && modelName != '-' ? modelName : 'Thiết bị di động');

    final displayBrand =
        brand.isNotEmpty && brand != '-' ? brand : (manufacturer.isNotEmpty ? manufacturer : platform);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tradeInNavy, AppColors.tradeInDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.tradeInNavy.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative glow
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tradeInBlue.withValues(alpha: 0.15),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row: Brand + Trade-in Ready Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayBrand.toUpperCase(),
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tradeInEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.tradeInEmerald.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.tradeInEmerald,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đủ điều kiện thu cũ',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.tradeInEmerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Device Name & Icon
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.tradeInBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.tradeInBlue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.smartphone_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Model: $modelName • Nền tảng: $platform',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Specs Badges Row (RAM, ROM, Origin, Camera)
                Row(
                  children: [
                    Expanded(
                      child: _SpecPill(
                        icon: Icons.memory_rounded,
                        label: 'RAM',
                        value: ramTotal != null ? '$ramTotal GB' : '4 GB',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SpecPill(
                        icon: Icons.storage_rounded,
                        label: 'Bộ nhớ',
                        value: romTotal != null ? '$romTotal GB' : '64 GB',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SpecPill(
                        icon: Icons.public_rounded,
                        label: 'Xuất xứ',
                        value: origin ?? 'Chính hãng',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Trade-In Subsidy Incentive Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.tradeInGold.withValues(alpha: 0.2),
                        AppColors.tradeInGoldDark.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tradeInGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: AppColors.tradeInGold,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ưu đãi trợ giá lên đời đến +2.000.000 đ',
                              style: AppTextStyles.voucherBadge.copyWith(
                                color: AppColors.tradeInGold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Định giá chuẩn & chính xác sau 60s kiểm định',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  const _SpecPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: AppColors.white70),
              const SizedBox(width: 3),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
