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
    required this.ramLabel,
    required this.romLabel,
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
  /// Nhãn RAM/ROM đã định dạng sẵn bởi `DiagnosticsHomeController`.
  ///
  /// KHÔNG tự tính lại từ `totalBytes` ở đây: trước kia widget có bản sao
  /// riêng của logic làm tròn, lại làm tròn về mốc GẦN NHẤT trong khi
  /// controller làm tròn LÊN theo một danh sách mốc khác — cùng một máy
  /// ~12GiB hiện "12 GB" ở màn chủ nhưng "16 GB" ở màn xác nhận và trong mã
  /// IT. Một nguồn duy nhất thì không lệch được nữa.
  final String ramLabel;
  final String romLabel;
  final String? marketingName;
  final String? deviceId;
  final int? batteryLevel;

  @override
  Widget build(BuildContext context) {
    final displayName =
        marketingName != null &&
                marketingName!.isNotEmpty &&
                marketingName != '-'
            ? marketingName!
            : (modelName.isNotEmpty && modelName != '-'
                ? modelName
                : LocaleKeys.diagnostics_home_default_device_name.trans());

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
            // 2. Khối nhận diện thiết bị chính (Biểu tượng + Tên thương mại + Mã Model)
            Row(
              children: [
                // Hộp chứa biểu tượng thiết bị
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

                // Tên máy & Thông tin meta
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

            // 3. Thông số phần cứng: RAM & Bộ nhớ trong (Thẻ giao diện sáng sạch)
            Row(
              children: [
                Expanded(
                  child: _CleanSpecCard(
                    icon: Icons.memory_rounded,
                    iconColor: AppColors.pviBlue,
                    category: 'RAM',
                    value: ramLabel,
                    subtitle: 'Bộ nhớ đệm',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _CleanSpecCard(
                    icon: Icons.sd_storage_rounded,
                    iconColor: AppColors.pviNavy,
                    category: 'BỘ NHỚ TRONG',
                    value: romLabel,
                    subtitle: 'Dung lượng lưu trữ',
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 4. Dải thông tin cam kết thẩm định
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
