import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TouchGridTestPage extends StatefulWidget {
  const TouchGridTestPage({super.key});

  @override
  State<TouchGridTestPage> createState() => _TouchGridTestPageState();
}

class _TouchGridTestPageState extends State<TouchGridTestPage> {
  // KÍCH THƯỚC Ô CỐ ĐỊNH
  static const double kCell = 48.0;

  final Set<int> _hit = <int>{};

  // Lưu layout hiện tại để dùng ngoài build
  int _rows = 0, _cols = 0, _total = 0;
  Rect _gridRect = Rect.zero;

  Timer? _idleTimer;
  Timer? _finalizeTimer;
  int _finalSecs = 5;
  bool get _isFinalizing => _finalizeTimer != null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startIdleTimer();
  }

  @override
  void dispose() {
    _cancelIdleTimer();
    _cancelFinalizeTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _finish({bool success = false}) {
    _cancelIdleTimer();
    _cancelFinalizeTimer();
    final ok = success || _hit.length >= _total;
    if (mounted) Navigator.of(context).pop(ok);
  }

  void _startIdleTimer() {
    _cancelIdleTimer();
    _idleTimer = Timer(const Duration(seconds: 5), _startFinalizeTimer);
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void _startFinalizeTimer() {
    _cancelFinalizeTimer();
    setState(() => _finalSecs = 5);
    _finalizeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_finalSecs <= 1) {
        _finish(); // kết thúc (false) khi idle
        return;
      }
      setState(() => _finalSecs--);
    });
  }

  void _cancelFinalizeTimer() {
    _finalizeTimer?.cancel();
    _finalizeTimer = null;
    if (mounted) setState(() => _finalSecs = 5);
  }

  void _onUserInteraction() {
    if (_isFinalizing) _cancelFinalizeTimer();
    _startIdleTimer();
  }

  void _markAtLocal(Offset globalLocal) {
    _onUserInteraction();

    // Chỉ nhận nếu chạm trong vùng lưới
    if (!_gridRect.contains(globalLocal)) return;

    final local = globalLocal - _gridRect.topLeft;
    final r = (local.dy / kCell).floor().clamp(0, _rows - 1);
    final c = (local.dx / kCell).floor().clamp(0, _cols - 1);
    final i = r * _cols + c;

    if (_hit.contains(i)) return;
    setState(() => _hit.add(i));

    // ✅ Đủ 100% ô → tự động kết thúc (pop true)
    if (_hit.length >= _total) {
      _finish(success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullW = constraints.maxWidth;
        final fullH = constraints.maxHeight;

        // Tính số cột/hàng dựa trên kích thước ô cố định
        _cols = math.max(1, (fullW / kCell).floor());
        _rows = math.max(1, (fullH / kCell).floor());
        _total = _rows * _cols;

        // Kích thước lưới thật sự (giữ nguyên size ô)
        final gridW = _cols * kCell;
        final gridH = _rows * kCell;

        // Căn giữa
        final gridLeft = (fullW - gridW) / 2;
        final gridTop = (fullH - gridH) / 2;
        _gridRect = Rect.fromLTWH(gridLeft, gridTop, gridW, gridH);

        return Stack(
          children: [
            // Lưới kích thước cố định, ô luôn vuông kCell × kCell
            Positioned.fromRect(
              rect: _gridRect,
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
                  final on = _hit.contains(i);
                  return SizedBox.square(
                    dimension: kCell,
                    child: Container(
                      color: on ? Colors.white : Colors.blue.shade900,
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Overlay đếm ngược khi idle
            if (_isFinalizing)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Không có tương tác',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Chip(
                          backgroundColor: Colors.red.shade400,
                          label: Text(
                            'Tự động kết thúc sau $_finalSecs s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chạm màn hình để tiếp tục kiểm tra',
                          style: TextStyle(color: Colors.white70),
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
      },
    );
  }
}
