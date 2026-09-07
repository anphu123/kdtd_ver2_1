/// ============================================================
/// AutoSuiteSection - Phần Khởi Động Test Tự Động
/// ============================================================
///
/// Widget hiển thị button để bắt đầu các test tự động.
/// Bao gồm:
/// - Tiêu đề và mô tả
/// - Button bắt đầu/đang chạy
/// ============================================================
library;

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

class AutoSuiteSection extends StatelessWidget {
  const AutoSuiteSection({
    super.key,
    required this.onStartAuto,
    required this.isRunning,
  });

  /// Callback khi nhấn nút bắt đầu
  final VoidCallback? onStartAuto;

  /// Đang chạy test hay không
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.tradeInBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.tradeInBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thẩm Định Chuẩn Thu Cũ',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.tradeInNavy,
                      ),
                    ),
                    Text(
                      'Định giá tự động chỉ trong 60 giây',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralGreyDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big 1-Touch Button
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: isRunning
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.tradeInBlue, AppColors.tradeInBlueLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: isRunning ? AppColors.neutralGreyLighter : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isRunning
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.tradeInBlue.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: isRunning ? null : onStartAuto,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRunning ? Icons.hourglass_empty_rounded : Icons.bolt_rounded,
                        color: isRunning ? AppColors.neutralGreyDark : AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRunning ? 'Đang Kiểm Định Máy...' : 'Bắt Đầu Thẩm Định Ngay',
                        style: AppTextStyles.button.copyWith(
                          color: isRunning ? AppColors.neutralGreyDark : AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Privacy note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.neutralGrey),
              const SizedBox(width: 4),
              Text(
                'Bảo mật dữ liệu tuyệt đối • Không lưu thông tin riêng tư',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutralGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
