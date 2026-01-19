/// ============================================================
/// AutoSuiteSection - Phần Khởi Động Test Tự Động
/// ============================================================
///
/// Widget hiển thị button để bắt đầu các test tự động.
/// Bao gồm:
/// - Tiêu đề và mô tả
/// - Button bắt đầu/đang chạy
/// ============================================================

import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';

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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyE5E5E5.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Kiểm Định Tự Động',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mô tả
          Text(
            'Chạy tất cả các bài test phần cứng tự động.\n'
            'Không cần tương tác người dùng.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.gray8F8F8F,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Button bắt đầu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onStartAuto,
              icon: Icon(
                isRunning ? Icons.hourglass_empty : Icons.play_arrow,
                size: 22,
              ),
              label: Text(
                isRunning ? 'Đang chạy...' : 'Bắt Đầu Kiểm Định',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Ghi chú cho user
          if (!isRunning) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Ứng dụng sẽ yêu cầu cấp quyền trước khi bắt đầu',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
