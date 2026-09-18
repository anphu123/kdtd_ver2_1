import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Device Info Section - Thiết kế Clean Light Minimalist theo chuẩn Trade-In Apple
/// Tông sáng tối giản, nền trắng cao cấp, viền mảnh tinh tế, typography phân cấp rõ ràng.
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
    this.marketingName,
    this.deviceId,
    this.batteryLevel,
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
  final String? marketingName;
  final String? deviceId;
  final int? batteryLevel;

  int? _toGiB(dynamic v) {
    if (v is! num || v <= 0) return null;
    const giB = 1024 * 1024 * 1024;
    final gb = v.toDouble() / giB;

    const standardSizes = [2, 3, 4, 6, 8, 12, 16, 24, 32, 64, 128, 256, 512, 1024];

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
                : LocaleKeys.diagnostics_home_default_device_name.trans());

    // final displayBrand =
    //     brand.isNotEmpty && brand != '-'
    //         ? brand
    //         : (manufacturer.isNotEmpty ? manufacturer : platform);

    final displayModel =
        modelName.isNotEmpty && modelName != '-' ? modelName : 'Chưa rõ mã';
    final displayPlatform =
        platform.isNotEmpty ? platform.toUpperCase() : 'HĐH';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.tradeInBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Bar: Brand Pill + Trade-In Eligible Status Pill
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // Brand Tag
            //     Container(
            //       padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
            //       decoration: BoxDecoration(
            //         color: AppColors.tradeInSurfaceBg,
            //         borderRadius: BorderRadius.circular(6.r),
            //         border: Border.all(
            //           color: AppColors.tradeInBorder,
            //           width: 0.8,
            //         ),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(
            //             Icons.verified_rounded,
            //             size: 13.sp,
            //             color: AppColors.tradeInBlue,
            //           ),
            //           SizedBox(width: 4.w),
            //           Text(
            //             displayBrand.toUpperCase(),
            //             style: AppTextStyles.badge.copyWith(
            //               color: AppColors.tradeInSlate,
            //               letterSpacing: 0.5,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),

            //     // Trade-in Status Badge
            //     Container(
            //       padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
            //       decoration: BoxDecoration(
            //         color: AppColors.tradeInEmeraldLight,
            //         borderRadius: BorderRadius.circular(6.r),
            //         border: Border.all(
            //           color: AppColors.tradeInEmeraldBorder,
            //           width: 0.8,
            //         ),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(
            //             Icons.check_circle_rounded,
            //             size: 13.sp,
            //             color: AppColors.tradeInEmerald,
            //           ),
            //           SizedBox(width: 4.w),
            //           Text(
            //             LocaleKeys.diagnostics_home_trade_in_eligible_badge.trans(),
            //             style: AppTextStyles.badge.copyWith(
            //               color: AppColors.tradeInEmerald,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

           // SizedBox(height: 14.h),

            // 2. Main Device Hero Row (Icon + Marketing Name + Model Meta)
            Row(
              children: [
                // Device Icon Container (Clean Minimalist Light)
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.pviRedLighter,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.pviRedBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.smartphone_rounded,
                    color: AppColors.tradeInBlue,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Device Name & Meta Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.heroTitle.copyWith(
                          color: AppColors.tradeInNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Model: $displayModel • $displayPlatform',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.tradeInSlateLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // 3. Hardware Specs: RAM & Bộ nhớ trong (Clean Light Tiles)
            Row(
              children: [
                Expanded(
                  child: _CleanSpecCard(
                    icon: Icons.memory_rounded,
                    iconColor: AppColors.pviBlue,
                    category: 'RAM',
                    value: ramTotal != null ? '$ramTotal GB' : '8 GB',
                    subtitle: 'Bộ nhớ đệm',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _CleanSpecCard(
                    icon: Icons.sd_storage_rounded,
                    iconColor: AppColors.pviNavy,
                    category: 'BỘ NHỚ TRONG',
                    value: romTotal != null ? '$romTotal GB' : '128 GB',
                    subtitle: 'Dung lượng lưu trữ',
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 4. Subtle Trust Guarantee Strip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.tradeInSurfaceBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.tradeInBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14.sp,
                    color: AppColors.tradeInBlue,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Thẩm định tự động 100% • Quy trình chuẩn xác',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.tradeInSlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '~2 phút',
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.tradeInNavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ thông số RAM / ROM phong cách Clean Light Minimalist
class _CleanSpecCard extends StatelessWidget {
  const _CleanSpecCard({
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String category;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.tradeInSurfaceBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.tradeInBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: iconColor),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  category,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.tradeInSlateLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.tradeInNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.tradeInSlateLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
