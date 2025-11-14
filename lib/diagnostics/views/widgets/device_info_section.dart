import 'package:flutter/material.dart';

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

    final displayName =
        marketingName != null &&
                marketingName!.isNotEmpty &&
                marketingName != '-'
            ? marketingName!
            : (modelName.isNotEmpty && modelName != '-'
                ? modelName
                : 'Không xác định');

    final displayBrand =
        brand.isNotEmpty && brand != '-'
            ? brand
            : (manufacturer.isNotEmpty ? manufacturer : platform);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5B7C99),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Phone Image at top
          Container(
            width: 140,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2.5,
              ),
            ),
            child: Stack(
              children: [
                // Screen
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.smartphone_rounded,
                          size: 64,
                          color: const Color(0xFF5B7C99).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Notch
                Positioned(
                  top: 6,
                  left: 48,
                  right: 48,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Grid - 2 rows x 2 columns
          Column(
            children: [
              // Row 1: Tên sản phẩm | Hãng
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.phone_android_rounded,
                      label: 'Tên sản phẩm',
                      value: displayName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.business_rounded,
                      label: 'Hãng',
                      value: displayBrand,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Row 2: Xuất xứ | RAM | ROM
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.public_rounded,
                      label: 'Xuất xứ',
                      value: origin ?? 'Không xác định',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.memory_rounded,
                      label: 'RAM',
                      value: ramTotal != null ? '$ramTotal GB' : 'N/A',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.storage_rounded,
                      label: 'ROM',
                      value: romTotal != null ? '$romTotal GB' : 'N/A',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Info Card widget
class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
