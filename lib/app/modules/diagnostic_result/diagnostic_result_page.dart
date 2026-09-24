import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/constants/diagnostic_result_constants.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/services/diagnostic_grade_service.dart';
import 'package:kdtd_ver2_1/app/data/services/price_estimation_service.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/modules/question_check/question_check_controller.dart';
import 'package:kdtd_ver2_1/app/core/constants/upgrade_program_constants.dart';
import 'package:kdtd_ver2_1/app/core/widgets/upgrade_program_dialogs.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';

/// Trang kết quả thẩm định (Trade-In) — KHÔNG còn phần lên đời máy mới,
/// chỉ hiển thị chứng nhận thẩm định + định giá thu cũ + chi tiết kiểm định.
class DiagnosticResultPage extends StatefulWidget {
  const DiagnosticResultPage({super.key});

  @override
  State<DiagnosticResultPage> createState() => _DiagnosticResultPageState();
}

class _DiagnosticResultPageState extends State<DiagnosticResultPage> {
  final DiagnosticsHomeController controller =
      Get.find<DiagnosticsHomeController>();
  PriceEstimate? priceEstimate;
  bool isLoadingPrice = true;
  bool _hasShownEligibilityDialog = false;

  @override
  void initState() {
    super.initState();
    _fetchPriceEstimate();
    // Serial đủ điều kiện nhưng máy rớt xuống dưới Loại 2 thì báo ngay khi mở màn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isUpgradeEligible.value == true &&
          controller.finalDeviceType >
              UpgradeProgramConstants.maxEligibleType &&
          !_hasShownEligibilityDialog) {
        _hasShownEligibilityDialog = true;
        UpgradeProgramDialogs.showDeviceNotEligibleDialog(
          DiagnosticGradeService.labelForType(controller.finalDeviceType),
        );
      }
    });
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
    final baseTradeInValue =
        priceEstimate?.estimatedPrice ??
        DiagnosticResultConstants.fallbackTradeInValueVnd;

    final displayName =
        controller.marketingName.isNotEmpty && controller.marketingName != '-'
            ? controller.marketingName
            : (controller.modelName.isNotEmpty && controller.modelName != '-'
                ? controller.modelName
                : LocaleKeys.diagnostic_result_default_device_name.trans());

    final gradeColor = _getGradeColor(controller.finalDeviceType);
    final gradeLabel = DiagnosticGradeService.labelForType(
      controller.finalDeviceType,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            onPressed: () => _shareTradeInCertificate(baseTradeInValue),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero header (navy)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 8.h,
                bottom: 44.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.pviNavy, AppColors.pviNavyDark],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 20.w),
                  Container(
                    width: 110.w,
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: FutureBuilder<String?>(
                        future: controller.getPhoneImageUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.pviNavyBorder,
                                ),
                              ),
                            );
                          }
                          final url = snapshot.data;
                          if (url != null && url.isNotEmpty) {
                            return Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.smartphone_outlined,
                                    size: 48.r,
                                    color: AppColors.tradeInSlateLight,
                                  ),
                            );
                          }
                          return Icon(
                            Icons.smartphone_outlined,
                            size: 48.r,
                            color: AppColors.tradeInSlateLight,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: AppColors.successBorder,
                                size: 14.r,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  LocaleKeys.diagnostic_result_certificate_badge
                                      .trans(),
                                  style: AppTextStyles.badgeSmall.copyWith(
                                    color: AppColors.successBorder,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          displayName,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: gradeColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            gradeLabel,
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
            ),

            // 2. Thẻ giá thu cũ
            Transform.translate(
              offset: Offset(0, -32.h),
              child: Container(
                // Bắt buộc có width: Container không đặt width sẽ co lại vừa
                // bằng chữ số tiền, khiến thẻ hẹp lơ lửng giữa màn hình.
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pviNavy.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.diagnostic_result_trade_in_price_label.trans(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    isLoadingPrice
                        ? SizedBox(
                          height: 36.h,
                          child: Center(
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.successDark,
                              ),
                            ),
                          ),
                        )
                        : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatPrice(baseTradeInValue),
                            style: AppTextStyles.priceDisplay.copyWith(
                              color: AppColors.successDark,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    SizedBox(height: 14.h),
                    Divider(color: AppColors.borderSubtle, height: 1),
                    SizedBox(height: 12.h),
                    // Dòng điểm sức khỏe — đặt ở đây thay vì trong hero vì
                    // cột chữ hero quá hẹp, chữ bị ngắt dòng xấu.
                    Text(
                      LocaleKeys.diagnostic_result_health_score_line.trans(
                        namedArgs: {'score': controller.score.toString()},
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Không cần SizedBox: Transform.translate chỉ dịch lúc vẽ nên ô
            // của thẻ giá vẫn chiếm chỗ cũ, tạo sẵn khoảng hở 32.h bên dưới.

            // 3. Thẻ chi tiết hạng mục — dạng danh sách thay vì lưới 2x2 vì
            // phần mô tả có độ dài rất khác nhau (câu trả lời khảo sát có thể
            // dài cả dòng), lưới ô cố định sẽ tràn chữ.
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildSpecRow(
                    icon: Icons.battery_full_rounded,
                    iconColor: AppColors.success,
                    label:
                        LocaleKeys.diagnostic_result_category_battery_label
                            .trans(),
                    value: _getBatteryLabel(),
                  ),
                  _buildSpecDivider(),
                  _buildSpecRow(
                    icon: Icons.smartphone_rounded,
                    iconColor: AppColors.pviBlue,
                    label:
                        LocaleKeys.diagnostic_result_category_screen_label
                            .trans(),
                    value: _getScreenAnswerLabel(),
                  ),
                  _buildSpecDivider(),
                  _buildSpecRow(
                    icon: Icons.touch_app_rounded,
                    iconColor: AppColors.pviBlue,
                    label:
                        LocaleKeys.diagnostic_result_category_touch_label
                            .trans(),
                    value: _getTouchLabel(),
                  ),
                  _buildSpecDivider(),
                  _buildSpecRow(
                    icon: Icons.verified_rounded,
                    iconColor: gradeColor,
                    label:
                        LocaleKeys
                            .diagnostic_result_category_classification_label
                            .trans(),
                    value: gradeLabel,
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // 4. Hai nút hành động
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.employeeCode);
                  },
                  icon: Icon(
                    Icons.swap_horizontal_circle_rounded,
                    color: AppColors.white,
                    size: 20.r,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pviRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  label: Text(
                    LocaleKeys.diagnostic_result_trade_button.trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 44.h,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.diagnostic_result_no_trade_button.trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.neutralGreyDark,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Một dòng hạng mục: icon tròn bên trái, tên hạng mục mờ ở trên và kết quả
  /// đậm ở dưới. Cao tự co theo độ dài kết quả nên không bao giờ tràn.
  Widget _buildSpecRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: iconColor, size: 18.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vạch ngăn giữa các dòng hạng mục, thụt vào cho thẳng cột chữ.
  Widget _buildSpecDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 66.w, right: 16.w),
      child: Divider(color: AppColors.borderSubtle, height: 1),
    );
  }

  String _getBatteryLabel() {
    final level = controller.batteryLevel;
    if (level != null) {
      return LocaleKeys.diagnostic_result_battery_level_desc.trans(
        namedArgs: {'level': level.toString()},
      );
    }
    return LocaleKeys.diagnostic_result_no_data.trans();
  }

  String _getScreenAnswerLabel() {
    if (Get.isRegistered<QuestionCheckController>()) {
      final qc = Get.find<QuestionCheckController>();
      final item = qc.applicableItems.firstWhereOrNull((i) => i.id == 'q3');
      if (item != null) {
        final ansValue = qc.answers['q3'];
        if (ansValue != null) {
          final choice = item.choices.firstWhereOrNull(
            (c) => c.value == ansValue,
          );
          if (choice != null) return choice.label;
        }
      }
    }
    return LocaleKeys.diagnostic_result_no_data.trans();
  }

  String _getTouchLabel() {
    final touchStep = controller.steps.firstWhereOrNull(
      (s) => s.code == 'touch-screen',
    );
    if (touchStep != null) {
      if (touchStep.status == DiagStatus.passed) {
        return LocaleKeys.diagnostic_result_touch_ok_desc.trans();
      } else if (touchStep.status == DiagStatus.failed) {
        return (touchStep.note != null && touchStep.note!.isNotEmpty)
            ? touchStep.note!
            : LocaleKeys.diagnostic_result_touch_needs_attention_desc.trans();
      }
    }
    return LocaleKeys.diagnostic_result_no_data.trans();
  }

  Color _getGradeColor(int gradeType) {
    if (gradeType == 1) return AppColors.pass;
    if (gradeType >= 4) return AppColors.fail;
    return AppColors.warning;
  }

  void _shareTradeInCertificate(int baseValue) {
    final text = LocaleKeys.diagnostic_result_share_certificate_template.trans(
      namedArgs: {
        'brand': controller.brand,
        'model': controller.modelName,
        'tradeInPrice': _formatPrice(baseValue),
      },
    );
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      LocaleKeys.diagnostic_result_snackbar_copied_title.trans(),
      LocaleKeys.diagnostic_result_snackbar_copied_message.trans(),
    );
  }
}
