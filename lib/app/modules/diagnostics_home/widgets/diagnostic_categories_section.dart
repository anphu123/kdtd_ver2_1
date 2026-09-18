import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Hiển thị 4 phân nhóm bài kiểm định chuẩn hóa - Phong cách Clean Light Minimalist
class DiagnosticCategoriesSection extends StatelessWidget {
  const DiagnosticCategoriesSection({
    super.key,
    this.totalTests,
  });

  /// Số bài kiểm định tùy chọn truyền vào; nếu null sẽ đọc động từ controller
  final int? totalTests;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DiagnosticsHomeController>()
        ? Get.find<DiagnosticsHomeController>()
        : null;
    final total = totalTests ??
        (controller?.total != null && controller!.total > 0
            ? controller.total
            : 13);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: AppColors.pviRed,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.diagnostics_home_categories_title.trans(),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tradeInNavy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: AppColors.pviRedLighter,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.pviRedBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  LocaleKeys.diagnostics_home_categories_badge.trans(
                    namedArgs: {'count': '$total'},
                  ),
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.pviRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.55,
            children: [
              _CategoryCard(
                icon: Icons.wifi_tethering_rounded,
                iconColor: AppColors.pviBlue,
                bgPillColor: AppColors.pviBlueLighter,
                title: LocaleKeys.diagnostics_home_cat_connectivity_title.trans(),
                subtitle:
                    LocaleKeys.diagnostics_home_cat_connectivity_sub.trans(),
                countTag: LocaleKeys.diagnostics_home_cat_tests_count.trans(
                  namedArgs: {'count': '3'},
                ),
              ),
              _CategoryCard(
                icon: Icons.tune_rounded,
                iconColor: AppColors.pviNavy,
                bgPillColor: AppColors.pviNavyLighter,
                title: LocaleKeys.diagnostics_home_cat_hardware_title.trans(),
                subtitle: LocaleKeys.diagnostics_home_cat_hardware_sub.trans(),
                countTag: LocaleKeys.diagnostics_home_cat_tests_count.trans(
                  namedArgs: {'count': '4'},
                ),
              ),
              _CategoryCard(
                icon: Icons.touch_app_rounded,
                iconColor: AppColors.pviRed,
                bgPillColor: AppColors.pviRedLighter,
                title: LocaleKeys.diagnostics_home_cat_screen_title.trans(),
                subtitle: LocaleKeys.diagnostics_home_cat_screen_sub.trans(),
                countTag: LocaleKeys.diagnostics_home_cat_tests_count.trans(
                  namedArgs: {'count': '3'},
                ),
              ),
              _CategoryCard(
                icon: Icons.headset_mic_rounded,
                iconColor: AppColors.tradeInEmerald,
                bgPillColor: AppColors.tradeInEmeraldLight,
                title: LocaleKeys.diagnostics_home_cat_audio_camera_title.trans(),
                subtitle:
                    LocaleKeys.diagnostics_home_cat_audio_camera_sub.trans(),
                countTag: LocaleKeys.diagnostics_home_cat_tests_count.trans(
                  namedArgs: {'count': '3'},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.iconColor,
    required this.bgPillColor,
    required this.title,
    required this.subtitle,
    required this.countTag,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgPillColor;
  final String title;
  final String subtitle;
  final String countTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.tradeInBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: bgPillColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.sp, color: iconColor),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.tradeInSurfaceBg,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: AppColors.tradeInBorder,
                    width: 0.6,
                  ),
                ),
                child: Text(
                  countTag,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tradeInSlateLight,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.tradeInNavy,
                  fontSize: 12.5.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.tradeInSlateLight,
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
