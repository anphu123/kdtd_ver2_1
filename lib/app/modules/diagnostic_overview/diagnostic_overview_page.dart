import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/model/question_check_item.dart';
import 'package:kdtd_ver2_1/app/data/services/diagnostic_grade_service.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_overview/diagnostic_overview_controller.dart';

class DiagnosticOverviewPage extends StatelessWidget {
  const DiagnosticOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiagnosticOverviewController());

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        title: Text(
          LocaleKeys.diagnostic_overview_appbar_title.trans(),
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.tradeInNavy),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.tradeInNavy),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Không cần chừa 120.h nữa: bottomNavigationBar nằm ngoài
                // vùng body nên không đè lên nội dung cuộn.
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: Column(
                  children: [
                    _buildGradeBadge(controller),
                    SizedBox(height: 18.h),
                    _buildFunctionCheckSection(controller),
                    SizedBox(height: 18.h),
                    _buildQuestionCheckSection(context, controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Dùng bottomNavigationBar, KHÔNG dùng bottomSheet: Scaffold gỡ bỏ
      // padding dưới của MediaQuery cho slot bottomSheet, khiến SafeArea bên
      // trong thanh nút mất tác dụng và nút bị thanh điều hướng che mất.
      bottomNavigationBar: _buildBottomBar(controller),
    );
  }

  Widget _buildGradeBadge(DiagnosticOverviewController controller) {
    return Obx(() {
      final gradeLabel = DiagnosticGradeService.labelForType(controller.finalDeviceType);
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.pviNavy,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.pviNavyBorder),
        ),
        child: Column(
          children: [
            Text(
              gradeLabel,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFunctionCheckSection(DiagnosticOverviewController controller) {
    return PviInsetGroupCard(
      headerTitle: LocaleKeys.diagnostic_overview_section_function_check.trans(),
      children: [
        Obx(() {
          final steps = controller.steps;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: steps.map((step) => _buildFunctionStepTile(step, controller)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildFunctionStepTile(DiagStep step, DiagnosticOverviewController controller) {
    final isPassed = step.status == DiagStatus.passed;
    final isFailed = step.status == DiagStatus.failed;
    final isRunning = step.status == DiagStatus.running;
    
    Color iconColor = AppColors.neutralGreyDark;
    IconData iconData = Icons.info_outline;

    if (isPassed) {
      iconColor = AppColors.pass;
      iconData = Icons.check_circle_rounded;
    } else if (isFailed) {
      iconColor = AppColors.warning;
      iconData = Icons.warning_rounded;
    } else if (step.status == DiagStatus.skipped) {
      iconColor = AppColors.tradeInSlateLight;
      iconData = Icons.remove_circle_outline;
    }

    return InkWell(
      onTap: isFailed && !isRunning ? () => controller.restartStep(step) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                step.title,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tradeInNavy),
              ),
            ),
            if (isFailed && !isRunning) ...[
              Icon(Icons.refresh, size: 16.r, color: AppColors.tradeInBlue),
              SizedBox(width: 10.w),
            ],
            isRunning
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tradeInBlue),
                  )
                : Icon(iconData, size: 18.r, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCheckSection(BuildContext context, DiagnosticOverviewController controller) {
    return PviInsetGroupCard(
      headerTitle: LocaleKeys.diagnostic_overview_section_question_check.trans(),
      children: [
        Obx(() {
          final items = controller.applicableItems;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map((item) => _buildQuestionItemTile(context, item, controller)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionItemTile(BuildContext context, QuestionCheckItem item, DiagnosticOverviewController controller) {
    final selectedValue = controller.answers[item.id];
    final selectedChoice = item.choices.firstWhereOrNull((c) => c.value == selectedValue);

    return InkWell(
      onTap: () => _showChoiceBottomSheet(context, item, controller),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tradeInNavy, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              selectedChoice?.label ?? '',
              style: AppTextStyles.caption.copyWith(color: AppColors.neutralGreyDark, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  void _showChoiceBottomSheet(BuildContext context, QuestionCheckItem item, DiagnosticOverviewController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.diagnostic_overview_bottom_sheet_title.trans(),
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.tradeInNavy, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tradeInSlate),
                ),
                SizedBox(height: 16.h),
                ...item.choices.map((choice) {
                  return Obx(() {
                    final isSelected = controller.answers[item.id] == choice.value;
                    return GestureDetector(
                      onTap: () {
                        controller.selectAnswer(item.id, choice.value);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.tradeInBlue.withValues(alpha: 0.1) : AppColors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInBorder,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInBorder,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                choice.label,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected ? AppColors.tradeInNavy : AppColors.tradeInSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(DiagnosticOverviewController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.tradeInBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: controller.onContinuePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tradeInBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                LocaleKeys.diagnostic_overview_btn_continue.trans(),
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
