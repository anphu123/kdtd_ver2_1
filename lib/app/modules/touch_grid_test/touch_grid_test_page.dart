import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/global_widgets/immersive_mode.dart';

import 'touch_grid_test_controller.dart';

/// Bài test lưới cảm ứng (UI thuần).
///
/// Toàn bộ nghiệp vụ (ô đã chạm, đếm idle, đếm ngược kết thúc, tự động
/// hoàn thành khi đủ 100%) sống trong [TouchGridTestController]; widget
/// này chỉ đọc các field `.obs` qua `Obx` và gọi lại các method của
/// controller khi người dùng tương tác. Việc tính số cột/hàng/kích thước
/// ô từ kích thước màn hình vẫn ở lại đây vì đó thuần là toán bố cục
/// (presentation-derived), không phải nghiệp vụ.
class TouchGridTestPage extends GetView<TouchGridTestController> {
  const TouchGridTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ImmersiveMode(
      child: _TouchGridBody(controller: controller),
    );
  }
}

class _TouchGridBody extends StatefulWidget {
  const _TouchGridBody({required this.controller});

  final TouchGridTestController controller;

  @override
  State<_TouchGridBody> createState() => _TouchGridBodyState();
}

class _TouchGridBodyState extends State<_TouchGridBody> {
  // Lưu layout hiện tại (thuần bố cục) để dùng khi chuyển đổi toạ độ chạm.
  int _rows = 0, _cols = 0, _total = 0;
  double _cellSize = 0;

  void _markAtLocal(Offset localPosition) {
    final r = (localPosition.dy / _cellSize).floor().clamp(0, _rows - 1);
    final c = (localPosition.dx / _cellSize).floor().clamp(0, _cols - 1);
    final i = r * _cols + c;
    widget.controller.markCell(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullW = constraints.maxWidth;
        final fullH = constraints.maxHeight;

        // Tính số cột/hàng để ô vuông vừa phải (khoảng 60-80px)
        // Ưu tiên 6 cột cho màn hình dọc, tự động tính hàng
        _cols = 6;
        _cellSize = fullW / _cols;
        _rows = (fullH / _cellSize).floor();
        _total = _rows * _cols;

        final total = _total;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.controller.setTotalCells(total);
        });

        return Obx(() {
          final hitCells = widget.controller.hitCells;

          return Stack(
            children: [
              // Lưới full màn hình
              Positioned.fill(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: _total,
                  itemBuilder: (_, i) {
                    final on = hitCells.contains(i);
                    return Container(
                      decoration: BoxDecoration(
                        color: on ? AppColors.passLight : AppColors.infoDarker,
                        border: Border.all(
                          color: AppColors.white30,
                          width: 1,
                        ),
                      ),
                      child: on
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.white,
                              size: 32,
                            )
                          : null,
                    );
                  },
                ),
              ),

              // Progress indicator
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiến độ: ${hitCells.length}/$_total',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_total == 0 ? 0 : hitCells.length / _total * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.passAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Overlay đếm ngược khi idle
              if (widget.controller.isFinalizing.value)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      color: AppColors.black54,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Không có tương tác',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.failLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Tự động kết thúc sau ${widget.controller.finalizeSecondsLeft.value} s',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chạm màn hình để tiếp tục kiểm tra',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Bắt toàn bộ chạm
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (e) => _markAtLocal(e.localPosition),
                  onPointerMove: (e) => _markAtLocal(e.localPosition),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
