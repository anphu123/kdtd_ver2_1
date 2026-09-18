import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/diagnostic_result_constants.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/model/upgrade_device_option.dart';
import 'package:kdtd_ver2_1/app/data/services/diagnostic_grade_service.dart';
import 'package:kdtd_ver2_1/app/data/services/price_estimation_service.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

/// Trang kết quả thẩm định & Lên đời máy mới (Trade-In & Upgrade)
class DiagnosticResultPage extends StatefulWidget {
  const DiagnosticResultPage({super.key});

  @override
  State<DiagnosticResultPage> createState() => _DiagnosticResultPageState();
}

class _DiagnosticResultPageState extends State<DiagnosticResultPage> {
  final DiagnosticsHomeController controller =
      Get.find<DiagnosticsHomeController>();
  late UpgradeDeviceOption selectedOption;
  final List<UpgradeDeviceOption> upgradeOptions =
      UpgradeDeviceOption.defaultOptions;
  PriceEstimate? priceEstimate;
  bool isLoadingPrice = true;

  @override
  void initState() {
    super.initState();
    selectedOption = upgradeOptions.first;
    _fetchPriceEstimate();
  }

  Future<void> _fetchPriceEstimate() async {
    // Dùng chung điểm số từ controller, tránh tính lại (dễ lệch với các màn khác)
    final score = controller.score;
    final ramGb = controller.info['ram']?['totalGb'] as int? ?? 4;
    final romGb = controller.info['rom']?['totalGb'] as int? ?? 64;

    try {
      final estimate = await PriceEstimationService.estimatePrice(
        modelName: controller.modelName,
        brand: controller.brand,
        score: score,
        ramGb: ramGb,
        romGb: romGb,
      );
      if (mounted) {
        setState(() {
          priceEstimate = estimate;
          isLoadingPrice = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingPrice = false;
        });
      }
    }
  }

  String _formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final total = controller.steps.length;
    final passed = controller.passedCount.value;
    final failed = controller.failedCount.value;
    final score = controller.score;

    final baseTradeInValue =
        priceEstimate?.estimatedPrice ??
        DiagnosticResultConstants.fallbackTradeInValueVnd;
    final totalSubsidy = selectedOption.subsidyAmount;
    final totalValuation = baseTradeInValue + totalSubsidy;
    final topUpAmount = selectedOption.calculateTopUp(baseTradeInValue);

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 18.r,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocaleKeys.diagnostic_result_appbar_title.trans(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: AppColors.white,
              size: 20.r,
            ),
            onPressed:
                () => _shareTradeInCertificate(
                  baseTradeInValue,
                  totalValuation,
                  topUpAmount,
                ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Certificate Hero Card
                _buildCertificateCard(
                  score,
                  baseTradeInValue,
                  totalSubsidy,
                  totalValuation,
                ),

                SizedBox(height: 18.h),

                // 2. Interactive Upgrade Showroom
                _buildUpgradeShowroom(baseTradeInValue, topUpAmount),

                SizedBox(height: 18.h),

                // 3. Trade-in Process 3 steps
                _buildTradeInStepsCard(),

                SizedBox(height: 18.h),

                // 4. Diagnostic Checklist Summary
                _buildDiagnosticBreakdown(total, passed, failed),

                SizedBox(height: 18.h),

                // Secondary actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          controller.startWithPermissionCheck();
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 18.r,
                          color: AppColors.pviNavy,
                        ),
                        label: Text(
                          LocaleKeys.diagnostic_result_retest_button.trans(),
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.pviNavy,
                            fontSize: 13.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(
                            color: AppColors.tradeInBorder,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.printTestResults();
                          Get.snackbar(
                            LocaleKeys.diagnostic_result_snackbar_printed_title
                                .trans(),
                            LocaleKeys
                                .diagnostic_result_snackbar_printed_message
                                .trans(),
                          );
                        },
                        icon: Icon(
                          Icons.print_outlined,
                          size: 18.r,
                          color: AppColors.pviNavy,
                        ),
                        label: Text(
                          LocaleKeys.diagnostic_result_export_report_button
                              .trans(),
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.pviNavy,
                            fontSize: 13.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(
                            color: AppColors.tradeInBorder,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sticky Bottom Checkout Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(topUpAmount),
          ),
        ],
      ),
    );
  }

  /// Card 1: Chứng Nhận Thẩm Định & Định Giá Máy Cũ
  Widget _buildCertificateCard(
    int score,
    int baseTradeInValue,
    int subsidy,
    int totalValuation,
  ) {
    final gradeText = DiagnosticGradeService.labelFromScore(score);

    final displayName =
        controller.marketingName.isNotEmpty && controller.marketingName != '-'
            ? controller.marketingName
            : (controller.modelName.isNotEmpty && controller.modelName != '-'
                ? controller.modelName
                : LocaleKeys.diagnostic_result_default_device_name.trans());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pviNavy,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.pviNavyBorder, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.tradeInEmerald,
                      size: 20.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      LocaleKeys.diagnostic_result_certificate_badge.trans(),
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.tradeInEmerald,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pviNavyLighter,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.pviNavyBorder, width: 0.8),
                  ),
                  child: Text(
                    gradeText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // Device Name
            Text(
              displayName,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              LocaleKeys.diagnostic_result_health_score_line.trans(
                namedArgs: {'score': '$score'},
              ),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.pviBlueLighter,
              ),
            ),

            SizedBox(height: 18.h),

            // Price Highlights Box
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.pviNavyLighter,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.pviNavyBorder,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.diagnostic_result_trade_in_price_label
                            .trans(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.pviBlueLighter,
                        ),
                      ),
                      isLoadingPrice
                          ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                          : Text(
                            _formatPrice(baseTradeInValue),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.tradeInGold,
                            size: 16.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            LocaleKeys.diagnostic_result_subsidy_label.trans(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.tradeInGold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+ ${_formatPrice(subsidy)}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.tradeInGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const Divider(
                      color: AppColors.pviNavyBorder,
                      height: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys
                                .diagnostic_result_total_deduction_label
                                .trans(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.tradeInEmeraldLight,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            LocaleKeys
                                .diagnostic_result_total_deduction_note
                                .trans(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.pviBlueLighter,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatPrice(totalValuation),
                        style: AppTextStyles.priceDisplay.copyWith(
                          color: AppColors.tradeInEmerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card 2: Interactive Upgrade Showroom
  Widget _buildUpgradeShowroom(int baseTradeInValue, int topUpAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.diagnostic_result_showroom_title.trans(),
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppColors.tradeInNavy,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  LocaleKeys.diagnostic_result_showroom_subtitle.trans(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGreyDark,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.tradeInGoldLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                LocaleKeys.diagnostic_result_installment_badge.trans(),
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.tradeInGoldDark,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // Horizontal Phone Carousel
        SizedBox(
          height: 175.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: upgradeOptions.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final option = upgradeOptions[index];
              final isSelected = option.id == selectedOption.id;
              final diff = option.calculateTopUp(baseTradeInValue);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 155.w,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.tradeInBlue
                              : AppColors.tradeInBorder,
                      width: isSelected ? 2.2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag + Select icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.tradeInBlue
                                      : AppColors.neutralGreyLight,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              option.tag,
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 9.sp,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.neutralGreyDark,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.tradeInBlue,
                              size: 16.r,
                            ),
                        ],
                      ),

                      // Device Icon
                      Center(
                        child: Icon(
                          option.icon,
                          size: 38.r,
                          color:
                              isSelected
                                  ? AppColors.tradeInBlue
                                  : AppColors.tradeInSlate,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.tradeInNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${option.storage} • ${option.colorName}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.neutralGreyDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            LocaleKeys.diagnostic_result_topup_only_label.trans(
                              namedArgs: {'amount': _formatPrice(diff)},
                            ),
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.passDark,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Real-Time Upgrade Math Card
        PviInsetGroupCard(
          headerTitle: LocaleKeys.diagnostic_result_upgrade_math_title.trans(
            namedArgs: {'name': selectedOption.name},
          ),
          headerTrailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 3.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.pviRedSurface,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.pviRedBorder, width: 0.8),
            ),
            child: Text(
              selectedOption.storage,
              style: AppTextStyles.badge.copyWith(
                color: AppColors.pviRed,
              ),
            ),
          ),
          children: [
            _buildMathRow(
              LocaleKeys.diagnostic_result_retail_price_label.trans(),
              selectedOption.formattedRetailPrice,
              isSub: false,
            ),
            _buildMathRow(
              LocaleKeys.diagnostic_result_deduct_trade_in_label.trans(),
              '- ${_formatPrice(baseTradeInValue)}',
              isHighlight: true,
            ),
            _buildMathRow(
              LocaleKeys.diagnostic_result_deduct_subsidy_label.trans(),
              '- ${selectedOption.formattedSubsidy}',
              isGold: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.diagnostic_result_actual_topup_label.trans(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.tradeInNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 12.r,
                          color: AppColors.pviBlue,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          LocaleKeys.diagnostic_result_installment_note.trans(
                            namedArgs: {
                              'amount': _formatPrice(
                                selectedOption.monthlyInstallment(
                                  topUpAmount,
                                ),
                              ),
                            },
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.pviBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _formatPrice(topUpAmount),
                  style: AppTextStyles.priceDisplay.copyWith(
                    color: AppColors.passDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMathRow(
    String label,
    String value, {
    bool isSub = true,
    bool isHighlight = false,
    bool isGold = false,
  }) {
    Color valueColor = AppColors.tradeInNavy;
    if (isHighlight) valueColor = AppColors.passDark;
    if (isGold) valueColor = AppColors.tradeInGoldDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSub ? AppColors.neutralGreyDark : AppColors.tradeInNavy,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Card 3: 3 Bước đổi máy
  Widget _buildTradeInStepsCard() {
    return PviInsetGroupCard(
      headerTitle: LocaleKeys.diagnostic_result_steps_card_title.trans(),
      children: [
        _buildStepRow(
          '1',
          LocaleKeys.diagnostic_result_step1_title.trans(),
          LocaleKeys.diagnostic_result_step1_desc.trans(),
          true,
        ),
        _buildStepRow(
          '2',
          LocaleKeys.diagnostic_result_step2_title.trans(),
          LocaleKeys.diagnostic_result_step2_desc.trans(),
          false,
        ),
        _buildStepRow(
          '3',
          LocaleKeys.diagnostic_result_step3_title.trans(),
          LocaleKeys.diagnostic_result_step3_desc.trans(),
          false,
        ),
      ],
    );
  }

  Widget _buildStepRow(String number, String title, String desc, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color:
                isDone
                    ? AppColors.tradeInEmerald
                    : AppColors.pviRedSurface,
            shape: BoxShape.circle,
            border: isDone ? null : Border.all(color: AppColors.pviRedBorder),
          ),
          child: Center(
            child:
                isDone
                    ? Icon(Icons.check, size: 14.r, color: AppColors.white)
                    : Text(
                      number,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.pviNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.tradeInNavy,
                ),
              ),
              Text(
                desc,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutralGreyDark,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card 4: Danh mục kiểm định chi tiết
  Widget _buildDiagnosticBreakdown(int total, int passed, int failed) {
    return PviInsetGroupCard(
      headerTitle: LocaleKeys.diagnostic_result_diagnostic_breakdown_title.trans(),
      headerTrailing: Row(
        children: [
          _buildMiniStat(
            LocaleKeys.diagnostic_result_passed_stat.trans(
              namedArgs: {'count': '$passed'},
            ),
            AppColors.pass,
          ),
          if (failed > 0) ...[
            SizedBox(width: 6.w),
            _buildMiniStat(
              LocaleKeys.diagnostic_result_failed_stat.trans(
                namedArgs: {'count': '$failed'},
              ),
              AppColors.fail,
            ),
          ],
        ],
      ),
      children: [
        ...controller.steps
            .take(DiagnosticResultConstants.stepsPreviewLimit)
            .map((step) => _buildStepResultTile(step)),
        if (controller.steps.length >
            DiagnosticResultConstants.stepsPreviewLimit)
          Center(
            child: TextButton.icon(
              onPressed: () => _showFullDiagnosticsDialog(),
              icon: Icon(
                Icons.list_alt_rounded,
                size: 16.r,
                color: AppColors.pviNavy,
              ),
              label: Text(
                LocaleKeys.diagnostic_result_view_all_tests.trans(
                  namedArgs: {'count': '${controller.steps.length}'},
                ),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.pviNavy,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStat(String text, Color color) {
    Color surface = AppColors.neutralGreyLight;
    Color border = AppColors.neutralGreyLighter;
    if (color == AppColors.pass || color == AppColors.success) {
      surface = AppColors.successSurface;
      border = AppColors.successBorder;
    } else if (color == AppColors.warning) {
      surface = AppColors.warningSurface;
      border = AppColors.warningBorder;
    } else if (color == AppColors.fail || color == AppColors.error) {
      surface = AppColors.pviRedSurface;
      border = AppColors.pviRedBorder;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: color, fontSize: 11.sp),
      ),
    );
  }

  Widget _buildStepResultTile(DiagStep step) {
    final isPassed = step.status == DiagStatus.passed;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            isPassed ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 18.r,
            color: isPassed ? AppColors.pass : AppColors.warning,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              step.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.tradeInNavy,
              ),
            ),
          ),
          Text(
            isPassed
                ? LocaleKeys.diagnostic_result_status_good.trans()
                : LocaleKeys.diagnostic_result_status_needs_attention.trans(),
            style: AppTextStyles.caption.copyWith(
              color: isPassed ? AppColors.pass : AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Bar
  Widget _buildStickyBottomBar(int topUpAmount) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.tradeInBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.diagnostic_result_sticky_topup_label.trans(
                      namedArgs: {'name': selectedOption.name},
                    ),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tradeInSlate,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    _formatPrice(topUpAmount),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.passDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: FilledButton.icon(
                    onPressed: () => _showUpgradeModal(topUpAmount),
                    icon: Icon(
                      Icons.rocket_launch_rounded,
                      size: 18.r,
                      color: AppColors.white,
                    ),
                    label: Text(
                      LocaleKeys.diagnostic_result_upgrade_now_button.trans(),
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pviRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal xác nhận lên đời máy mới
  void _showUpgradeModal(int topUpAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.tradeInBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.swap_horizontal_circle_rounded,
                    color: AppColors.pviNavy,
                    size: 24.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    LocaleKeys.diagnostic_result_modal_title.trans(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.pviNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.tradeInSurfaceBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.tradeInBorder),
                ),
                child: Column(
                  children: [
                    _buildModalRow(
                      LocaleKeys.diagnostic_result_modal_old_device_label.trans(),
                      '${controller.brand} ${controller.modelName}',
                    ),
                    SizedBox(height: 8.h),
                    _buildModalRow(
                      LocaleKeys.diagnostic_result_modal_new_device_label.trans(),
                      '${selectedOption.name} (${selectedOption.storage})',
                    ),
                    SizedBox(height: 8.h),
                    _buildModalRow(
                      LocaleKeys.diagnostic_result_modal_subsidy_label.trans(),
                      '+ ${selectedOption.formattedSubsidy}',
                      isGold: true,
                    ),
                    Divider(
                      height: 16.h,
                      color: AppColors.tradeInBorder,
                    ),
                    _buildModalRow(
                      LocaleKeys.diagnostic_result_modal_total_topup_label.trans(),
                      _formatPrice(topUpAmount),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.diagnostic_result_modal_delivery_method_label.trans(),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.tradeInNavy,
                ),
              ),
              SizedBox(height: 8.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.pviNavy,
                ),
                title: Text(
                  LocaleKeys.diagnostic_result_modal_delivery_title.trans(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.tradeInNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  LocaleKeys.diagnostic_result_modal_delivery_subtitle.trans(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGreyDark,
                  ),
                ),
                trailing: const Icon(
                  Icons.radio_button_checked,
                  color: AppColors.pviRed,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      LocaleKeys.diagnostic_result_snackbar_success_title.trans(),
                      LocaleKeys.diagnostic_result_snackbar_success_message.trans(
                        namedArgs: {
                          'orderId': '${DateTime.now().millisecondsSinceEpoch}',
                        },
                      ),
                      backgroundColor: AppColors.pass,
                      colorText: AppColors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pviRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.diagnostic_result_modal_confirm_button.trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(
    String label,
    String value, {
    bool isGold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutralGreyDark,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color:
                isTotal
                    ? AppColors.passDark
                    : isGold
                    ? AppColors.tradeInGoldDark
                    : AppColors.tradeInNavy,
            fontSize: isTotal ? 16.sp : 14.sp,
          ),
        ),
      ],
    );
  }

  void _showFullDiagnosticsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              LocaleKeys.diagnostic_result_full_diagnostics_dialog_title.trans(),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.steps.length,
                itemBuilder: (context, index) {
                  final step = controller.steps[index];
                  return _buildStepResultTile(step);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.diagnostic_result_close_button.trans()),
              ),
            ],
          ),
    );
  }

  void _shareTradeInCertificate(int baseValue, int totalValuation, int topUp) {
    final text = LocaleKeys.diagnostic_result_share_certificate_template.trans(
      namedArgs: {
        'brand': controller.brand,
        'model': controller.modelName,
        'tradeInPrice': _formatPrice(baseValue),
        'subsidy': _formatPrice(selectedOption.subsidyAmount),
        'totalDeduction': _formatPrice(totalValuation),
        'optionName': selectedOption.name,
        'topUp': _formatPrice(topUp),
      },
    );
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      LocaleKeys.diagnostic_result_snackbar_copied_title.trans(),
      LocaleKeys.diagnostic_result_snackbar_copied_message.trans(),
    );
  }
}
