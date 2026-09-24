import 'package:flutter/material.dart';

/// Vùng chạm có phản hồi co nhẹ (AnimatedScale) khi nhấn, dùng cho thẻ/nút
/// tự vẽ. Không có ripple để giữ nét phẳng của hệ PVI; [onTap] null = vô hiệu.
class PviPressable extends StatefulWidget {
  const PviPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.98,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;

  @override
  State<PviPressable> createState() => _PviPressableState();
}

class _PviPressableState extends State<PviPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
