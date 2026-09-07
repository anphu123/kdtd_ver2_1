import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Widget các nút hành động cho việc thu mua
class PurchaseActionButtons extends StatelessWidget {
  final int estimatedPrice;
  final String modelName;
  final String brand;
  final int score;

  const PurchaseActionButtons({
    super.key,
    required this.estimatedPrice,
    required this.modelName,
    required this.brand,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút Thu mua ngay
          FilledButton.icon(
            onPressed: () => _showPurchaseDialog(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.shopping_cart, size: 24),
            label: Text(
              'Thu mua ngay',
              style: AppTextStyles.button.copyWith(fontSize: 18),
            ),
          ),

          const SizedBox(height: 12),

          // Nút Lưu báo giá
          OutlinedButton.icon(
            onPressed: () => _saveQuote(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.save_alt),
            label: Text('Lưu báo giá', style: AppTextStyles.bodyLarge),
          ),

          const SizedBox(height: 12),

          // Nút Chia sẻ kết quả
          OutlinedButton.icon(
            onPressed: () => _shareResult(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.share),
            label: Text(
              'Chia sẻ kết quả',
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận thu mua'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thiết bị: $brand $modelName'),
                const SizedBox(height: 8),
                Text('Điểm đánh giá: $score/100'),
                const SizedBox(height: 8),
                Text(
                  'Giá thu mua: ${_formatPrice(estimatedPrice)}',
                  style: AppTextStyles.statValue.copyWith(
                    fontSize: 18,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn có muốn tiếp tục thu mua thiết bị này?',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processPurchase(context);
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.green),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  void _processPurchase(BuildContext context) {
    // TODO: Implement purchase logic
    // - Tạo đơn thu mua
    // - Lưu vào database
    // - Gửi thông báo
    // - In phiếu thu mua

    Get.snackbar(
      'Thành công',
      'Đã tạo đơn thu mua. Mã đơn: #${DateTime.now().millisecondsSinceEpoch}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.green,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: AppColors.white),
    );

    // Navigate to purchase details or print receipt
    _showReceiptDialog(context);
  }

  void _showReceiptDialog(BuildContext context) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final date = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Phiếu thu mua'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã đơn: #$orderId'),
                  Text('Ngày: ${date.day}/${date.month}/${date.year}'),
                  const Divider(),
                  Text('Thiết bị: $brand $modelName'),
                  Text('Điểm: $score/100'),
                  Text('Giá: ${_formatPrice(estimatedPrice)}'),
                  const Divider(),
                  Text(
                    'Cảm ơn quý khách!',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Implement print receipt
                  Get.snackbar(
                    'In phiếu',
                    'Đang in phiếu thu mua...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('In phiếu'),
              ),
            ],
          ),
    );
  }

  void _saveQuote(BuildContext context) {
    // TODO: Save quote to database or file
    Get.snackbar(
      'Đã lưu',
      'Báo giá đã được lưu vào hệ thống',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blue,
      colorText: AppColors.white,
      icon: const Icon(Icons.save, color: AppColors.white),
    );
  }

  void _shareResult(BuildContext context) {
    final text = '''
🔍 KẾT QUẢ KIỂM ĐỊNH THIẾT BỊ

📱 Thiết bị: $brand $modelName
⭐ Điểm đánh giá: $score/100
💰 Giá thu mua: ${_formatPrice(estimatedPrice)}

---
Được kiểm định bởi [Tên cửa hàng]
''';

    Clipboard.setData(ClipboardData(text: text));

    Get.snackbar(
      'Đã sao chép',
      'Kết quả đã được sao chép vào clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blue,
      colorText: AppColors.white,
      icon: const Icon(Icons.content_copy, color: AppColors.white),
    );

    // TODO: Implement share via social media, SMS, email
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}
