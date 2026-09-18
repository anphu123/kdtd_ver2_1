import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/modules/test_runner/test_runner_page.dart';

/// Màn hình Trung Gian 2: Hướng Dẫn Chuẩn Bị Trước Khi Kiểm Tra Tính Năng
/// Chuẩn bị thiết bị trước khi bước vào 13 bài test kiểm định
class PreTestPreparationGuidePage extends StatelessWidget {
  const PreTestPreparationGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.pre_test_guide_appbar_title.trans(),
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 1. Stepper chuyển tiếp giữa Bước 2 và Bước 3
          const PviModernistStepper(
            currentStep: 2,
            completedSteps: {1, 2},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Protocol Header Card
                  _buildProtocolHeader(),
                  SizedBox(height: 16.h),

                  // 3. Section Header
                  _buildSectionHeader(
                    title: '5 BƯỚC CHUẨN BỊ THIẾT BỊ',
                    subtitle: 'Thực hiện nhanh để bài test đạt độ chính xác tối đa',
                    icon: Icons.checklist_rounded,
                  ),
                  SizedBox(height: 8.h),

                  // 4. Inset Grouped Preparation Steps
                  _buildGuideInsetGroup(),
                  SizedBox(height: 16.h),

                  // 5. Security Note Card
                  _buildSecurityNote(),
                ],
              ),
            ),
          ),
          // 6. Sticky Bottom Action Dock
          _buildBottomActionDock(),
        ],
      ),
    );
  }

  Widget _buildProtocolHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.pviRedSurface,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.pviRedBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.pviRed,
                      size: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'PVI ASSURANCE',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.pviRed,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.pviNavySurface,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.pviNavyBorder),
                ),
                child: Text(
                  'CHUẨN BỊ KIỂM ĐỊNH',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.pviNavy,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.pviRedSurface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.pviRedBorder, width: 1.2),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: AppColors.pviRed,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.pre_test_guide_header_title.trans(),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.tradeInNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Thời gian ước tính: ~60 giây',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            LocaleKeys.pre_test_guide_header_description.trans(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11.5.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: AppColors.tradeInNavy),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppTextStyles.badge.copyWith(
                fontSize: 11.sp,
                color: AppColors.tradeInNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideInsetGroup() {
    final steps = [
      _GuideStepData(
        index: '1',
        icon: Icons.lightbulb_rounded,
        title: LocaleKeys.pre_test_guide_step1_title.trans(),
        description: LocaleKeys.pre_test_guide_step1_desc.trans(),
        accentColor: AppColors.warning,
        surfaceColor: AppColors.warningSurface,
      ),
      _GuideStepData(
        index: '2',
        icon: Icons.volume_up_rounded,
        title: LocaleKeys.pre_test_guide_step2_title.trans(),
        description: LocaleKeys.pre_test_guide_step2_desc.trans(),
        accentColor: AppColors.pviNavy,
        surfaceColor: AppColors.pviNavySurface,
      ),
      _GuideStepData(
        index: '3',
        icon: Icons.phonelink_setup_rounded,
        title: LocaleKeys.pre_test_guide_step3_title.trans(),
        description: LocaleKeys.pre_test_guide_step3_desc.trans(),
        accentColor: AppColors.tradeInEmerald,
        surfaceColor: AppColors.tradeInEmeraldLight,
      ),
      _GuideStepData(
        index: '4',
        icon: Icons.cleaning_services_rounded,
        title: LocaleKeys.pre_test_guide_step4_title.trans(),
        description: LocaleKeys.pre_test_guide_step4_desc.trans(),
        accentColor: AppColors.pviBlue,
        surfaceColor: AppColors.pviBlueSurface,
      ),
      _GuideStepData(
        index: '5',
        icon: Icons.wifi_rounded,
        title: LocaleKeys.pre_test_guide_step5_title.trans(),
        description: LocaleKeys.pre_test_guide_step5_desc.trans(),
        accentColor: AppColors.pviRed,
        surfaceColor: AppColors.pviRedSurface,
      ),
    ];

    return PviInsetGroupCard(
      dividerIndent: 56.w,
      children: steps.map((step) => _buildStepRow(step)).toList(),
    );
  }

  Widget _buildStepRow(_GuideStepData step) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: step.surfaceColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: step.accentColor == AppColors.pviRed
                    ? AppColors.pviRedBorder
                    : AppColors.borderSubtle,
              ),
            ),
            child: Icon(step.icon, color: step.accentColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.tradeInNavy,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        step.index,
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        step.title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.tradeInNavy,
                          fontSize: 13.5.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  step.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.5.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.tradeInEmeraldLight,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.tradeInEmeraldBorder),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 20.sp,
              color: AppColors.tradeInEmerald,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cam Kết Bảo Mật PVI',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.tradeInNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  LocaleKeys.pre_test_guide_security_note.trans(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.5.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: FilledButton.icon(
            onPressed: () {
              Get.off(() => const TestRunnerPage());
            },
            icon: Icon(
              Icons.play_arrow_rounded,
              color: AppColors.white,
              size: 22.sp,
            ),
            label: Text(
              'BẮT ĐẦU KIỂM ĐỊNH (13 BÀI TEST) →',
              style: AppTextStyles.button.copyWith(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pviRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideStepData {
  final String index;
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final Color surfaceColor;

  const _GuideStepData({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.surfaceColor,
  });
}

