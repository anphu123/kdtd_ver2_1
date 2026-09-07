import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bật chế độ toàn màn hình (immersive) khi mở, trả lại bình thường khi
/// đóng — dùng cho các bài test cần ẩn thanh trạng thái/điều hướng.
class ImmersiveMode extends StatefulWidget {
  const ImmersiveMode({super.key, required this.child});

  final Widget child;

  @override
  State<ImmersiveMode> createState() => _ImmersiveModeState();
}

class _ImmersiveModeState extends State<ImmersiveMode> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
