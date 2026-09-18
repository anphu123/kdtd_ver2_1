import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/services/diagnostic_grade_service.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

/// Màn hình thông báo phân hạng thiết bị khi có lỗi phần cứng (Hạng C / Hạng D)
/// Giúp khách hàng yên tâm rằng máy vẫn được thu cũ và trợ giá lên đời mới.
class FailedTestsWarningPage extends StatelessWidget {
  final List<DiagStep> failedSteps;
  final int score;

  const FailedTestsWarningPage({
    super.key,
    required this.failedSteps,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    // Dùng chung ngưỡng xếp hạng với trang kết quả, tránh lệch hạng giữa 2 màn
    final grade = DiagnosticGradeService.letterFromScore(score);

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.failed_tests_warning_appbar_title.trans(),
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Certificate / Grading Card
                  _buildGradingCard(grade),
                  SizedBox(height: 14.h),

                  // 2. Subsidy Voucher Callout
                  _buildSubsidyVoucher(grade),
                  SizedBox(height: 16.h),

                  // 3. Section Header
                  _buildSectionHeader(
                    title: 'CHI TIẾT LINH KIỆN CẦN LƯU Ý',
                    subtitle: '${failedSteps.length} linh kiện phản hồi chưa đạt chuẩn',
                    icon: Icons.assignment_late_outlined,
                  ),
                  SizedBox(height: 8.h),

                  // 4. Failed Tests Inset Group
                  _buildFailedTestsInsetGroup(),
                  SizedBox(height: 16.h),

                  // 5. Trade-in benefits reassurance
                  _buildReassuranceCard(),
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

  Widget _buildGradingCard(String grade) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.warningDark,
                      size: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'PVI ASSURANCE',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.warningDark,
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
                  'Điểm sức khỏe: $score/100',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.pviNavy,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            width: 54.w,
            height: 54.h,
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warningBorder, width: 1.5),
            ),
            child: Icon(
              Icons.sync_alt_rounded,
              color: AppColors.warningDark,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            LocaleKeys.failed_tests_warning_eligible_title.trans(),
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.tradeInNavy,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            LocaleKeys.failed_tests_warning_eligible_description.trans(
              namedArgs: {
                'count': '${failedSteps.length}',
                'grade': grade,
              },
            ),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 12.sp,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubsidyVoucher(String grade) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warningBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warningBorder),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: AppColors.warningDark,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.failed_tests_warning_subsidy_offer_title.trans(
                    namedArgs: {'grade': grade},
                  ),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.warningDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  LocaleKeys.failed_tests_warning_subsidy_offer_description.trans(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.tradeInNavy,
                    fontSize: 11.5.sp,
                    height: 1.3,
                  ),
                ),
              ],
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

  Widget _buildFailedTestsInsetGroup() {
    return PviInsetGroupCard(
      dividerIndent: 56.w,
      children: failedSteps.map((step) => _buildFailedItemRow(step)).toList(),
    );
  }

  Widget _buildFailedItemRow(DiagStep step) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.pviRedSurface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.pviRedBorder),
            ),
            child: Icon(_getIcon(step.code), color: AppColors.pviRed, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.tradeInNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                  ),
                ),
                if (step.note != null && step.note!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    step.note!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.warningBorder),
            ),
            child: Text(
              LocaleKeys.failed_tests_warning_needs_maintenance.trans(),
              style: AppTextStyles.badge.copyWith(
                color: AppColors.warningDark,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReassuranceCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.tradeInEmerald,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.failed_tests_warning_benefits_title.trans(),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.tradeInNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildBulletPoint(LocaleKeys.failed_tests_warning_benefit_1.trans()),
          _buildBulletPoint(LocaleKeys.failed_tests_warning_benefit_2.trans()),
          _buildBulletPoint(LocaleKeys.failed_tests_warning_benefit_3.trans()),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h, right: 8.w),
            width: 5.w,
            height: 5.h,
            decoration: const BoxDecoration(
              color: AppColors.pviRed,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tradeInNavy,
                fontSize: 11.5.sp,
                height: 1.35,
              ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton.icon(
                onPressed: () {
                  Get.off(() => const DiagnosticResultPage());
                },
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 20.sp,
                ),
                label: Text(
                  LocaleKeys.failed_tests_warning_view_valuation_button.trans(),
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
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.find<DiagnosticsHomeController>().startWithPermissionCheck();
                },
                icon: Icon(Icons.refresh_rounded, size: 16.sp, color: AppColors.tradeInNavy),
                label: Text(
                  LocaleKeys.failed_tests_warning_retest_button.trans(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.tradeInNavy,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String code) {
    switch (code) {
      case 'battery':
        return Icons.battery_alert_rounded;
      case 'screen':
        return Icons.phone_android_rounded;
      case 'touch':
        return Icons.touch_app_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'speaker':
        return Icons.volume_up_rounded;
      case 'mic':
        return Icons.mic_rounded;
      case 'ear':
        return Icons.hearing_rounded;
      case 'vibrate':
        return Icons.vibration_rounded;
      case 'keys':
        return Icons.keyboard_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'bt':
        return Icons.bluetooth_rounded;
      case 'nfc':
        return Icons.nfc_rounded;
      case 'gps':
        return Icons.location_on_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
