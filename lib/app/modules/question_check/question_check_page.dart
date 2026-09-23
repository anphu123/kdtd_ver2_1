import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/modules/question_check/question_check_controller.dart';

class QuestionCheckPage extends GetView<QuestionCheckController> {
  const QuestionCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ put nếu chưa đăng ký — build() có thể chạy lại nhiều lần (đổi
    // orientation, MediaQuery...), gọi Get.put lại sẽ tạo controller MỚI và
    // xoá sạch answers người dùng đã chọn.
    if (!Get.isRegistered<QuestionCheckController>()) {
      Get.put(QuestionCheckController(), permanent: true);
    }

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        title: Text(
          LocaleKeys.question_check_title.trans(),
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
              child: Obx(() {
                final items = controller.applicableItems;
                if (items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildQuestionCard(item);
                  },
                );
              }),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.tradeInNavy,
            ),
          ),
          SizedBox(height: 12.h),
          ...item.choices.map<Widget>((choice) {
            return Obx(() {
              final isSelected = controller.answers[item.id] == choice.value;
              return GestureDetector(
                onTap: () => controller.selectAnswer(item.id, choice.value),
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.tradeInBorder),
        ),
      ),
      child: Obx(() {
        final isComplete = controller.isComplete;
        return SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: isComplete ? controller.onContinuePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tradeInBlue,
              disabledBackgroundColor: AppColors.tradeInBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              LocaleKeys.question_check_btn_continue.trans(),
              style: AppTextStyles.button.copyWith(
                color: isComplete ? AppColors.white : AppColors.tradeInSlateLight,
              ),
            ),
          ),
        );
      }),
    );
  }
}
