import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.shopping_cart, size: 24),
            label: const Text(
              'Thu mua ngay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            label: const Text('Lưu báo giá', style: TextStyle(fontSize: 16)),
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
            label: const Text(
              'Chia sẻ kết quả',
              style: TextStyle(fontSize: 16),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn có muốn tiếp tục thu mua thiết bị này?',
                  style: TextStyle(fontSize: 14),
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
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
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
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
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
                  const Text(
                    'Cảm ơn quý khách!',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.save, color: Colors.white),
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
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.content_copy, color: Colors.white),
    );

    // TODO: Implement share via social media, SMS, email
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}
