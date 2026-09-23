import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
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
    // Dialog.fullscreen: hiện qua Get.dialog (không đẩy route/page mới,
    // đồng bộ cách hiện popup như Mic/Speaker/Earpiece) nhưng vẫn chiếm
    // trọn màn hình — bắt buộc vì bài test cần đo chạm trên toàn bộ diện
    // tích màn hình, không thể thu nhỏ như dialog thường.
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: ImmersiveMode(child: _TouchGridBody(controller: controller)),
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
  // Chiều rộng và chiều cao ô được tính RIÊNG (_cellW/_cellH) để ô lưới lấp
  // đầy đúng 100% kích thước màn hình, không để dư "vùng chết" nào — nếu
  // dùng chung 1 kích thước ô vuông rồi floor() số hàng, phần dư ở đáy màn
  // hình sẽ bị clamp() gán nhầm hết cho hàng cuối, gây sai số đếm ô.
  int _rows = 0, _cols = 0, _total = 0;
  double _cellW = 0, _cellH = 0;

  void _markAtLocal(Offset localPosition) {
    final r = (localPosition.dy / _cellH).floor().clamp(0, _rows - 1);
    final c = (localPosition.dx / _cellW).floor().clamp(0, _cols - 1);
    final i = r * _cols + c;
    widget.controller.markCell(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullW = constraints.maxWidth;
        final fullH = constraints.maxHeight;

        // Tính số cột theo kích thước ô mục tiêu (~50px) thay vì cố định 6
        // cột — ô nhỏ hơn 6-cột-mặc-định giúp phát hiện được nhiều vùng cảm
        // ứng hư nhỏ hơn, nhưng vẫn đủ lớn để nhìn rõ từng ô (36px trước đó
        // quá nhỏ, khó quan sát).
        // Dùng round() (không floor()) rồi CHIA LẠI fullH cho đúng _rows để
        // _cellH lấp đầy vừa khít chiều cao màn hình — không còn dư "vùng
        // chết" ở đáy (trước đây floor() để dư phần lẻ, bị clamp() gán
        // nhầm cho hàng cuối, gây sai số đếm ô). Ô có thể lệch vuông một
        // chút (chấp nhận được) để đổi lấy việc chạm phủ đúng 100% màn hình.
        const targetCellSize = 50.0;
        _cols = (fullW / targetCellSize).round().clamp(5, 20);
        _cellW = fullW / _cols;
        _rows = (fullH / _cellW).round().clamp(1, 1000);
        _cellH = fullH / _rows;
        _total = _rows * _cols;

        final total = _total;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.controller.setTotalCells(total);
        });

        // KHÔNG bọc 1 Obx to bao trùm cả lưới nữa — trước đây mỗi lần chạm
        // 1 ô là toàn bộ ~100-150 ô của GridView bị rebuild lại hết (dù chỉ
        // 1 ô đổi màu), khiến việc tô màu bị trễ/giật khi vuốt nhanh. Giờ
        // GridView tĩnh (không nằm trong Obx), mỗi Ô tự có Obx RIÊNG bên
        // trong itemBuilder — chạm ô nào chỉ ô đó rebuild, mượt hơn hẳn.
        return Stack(
          children: [
            // Lưới full màn hình — LUÔN vẽ (kể cả trước khi bấm Bắt đầu)
            // để người dùng thấy ngay lưới, chỉ có tương tác là bị khoá.
            Positioned.fill(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _cols,
                  childAspectRatio: _cellW / _cellH,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: _total,
                itemBuilder: (_, i) {
                  // Thiết kế tối giản: nền trắng, ô đã chạm tô đen — không
                  // dùng icon/màu xanh-dương rối mắt như trước. Obx riêng
                  // từng ô để chạm 1 ô không kéo cả lưới rebuild theo.
                  return Obx(() {
                    final on = widget.controller.hitCells.contains(i);
                    return Container(
                      decoration: BoxDecoration(
                        color: on ? AppColors.black : AppColors.white,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                    );
                  });
                },
              ),
            ),

            // Bắt toàn bộ chạm — tách riêng khỏi GridView (không lồng
            // Stack trong Stack), khoá/mở bằng IgnorePointer tường minh
            // theo [hasStarted]. Obx riêng, nhỏ, chỉ đổi khi bấm Bắt đầu
            // (không đổi theo từng ô chạm) nên không góp phần gây trễ.
            Positioned.fill(
              child: Obx(() {
                return IgnorePointer(
                  ignoring: !widget.controller.hasStarted.value,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (e) => _markAtLocal(e.localPosition),
                    onPointerMove: (e) => _markAtLocal(e.localPosition),
                  ),
                );
              }),
            ),

            // Popup mở đầu: chờ người dùng bấm "Bắt đầu" mới tính giờ và
            // ghi nhận chạm — tránh tính nhầm lúc còn đang đọc hướng dẫn.
            // Không còn thanh "Tiến độ: x/y" nổi thường trực nữa (rối mắt).
            Obx(() {
              if (widget.controller.hasStarted.value) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: Container(
                  color: AppColors.black54,
                  alignment: Alignment.center,
                  child: _buildPopupCard(
                    title: LocaleKeys.touch_grid_test_start_title.trans(),
                    subtitle:
                        LocaleKeys.touch_grid_test_start_description.trans(),
                    footer: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.controller.beginTest,
                        child: Text(
                          LocaleKeys.touch_grid_test_start_button.trans(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Popup đếm ngược khi idle — cùng kiểu popup với màn mở đầu để
            // đồng bộ giao diện, thay vì banner nền tối phủ nguyên màn hình.
            Obx(() {
              if (!widget.controller.isFinalizing.value) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppColors.black54,
                    alignment: Alignment.center,
                    child: _buildPopupCard(
                      title: LocaleKeys.touch_grid_test_no_interaction.trans(),
                      badge: LocaleKeys.touch_grid_test_auto_finish_in.trans(
                        namedArgs: {
                          'seconds':
                              '${widget.controller.finalizeSecondsLeft.value}',
                        },
                      ),
                      subtitle:
                          LocaleKeys.touch_grid_test_touch_to_continue.trans(),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// Thẻ popup dùng chung cho màn mở đầu và cảnh báo idle — đồng bộ giao
  /// diện thay vì mỗi chỗ tự vẽ 1 kiểu khác nhau.
  Widget _buildPopupCard({
    required String title,
    String? subtitle,
    String? badge,
    Widget? footer,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (badge != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.failLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                badge,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
          if (subtitle != null) ...[
            SizedBox(height: 12.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (footer != null) ...[SizedBox(height: 20.h), footer],
        ],
      ),
    );
  }
}
