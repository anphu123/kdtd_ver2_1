import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TouchGridTestPage extends StatefulWidget {
  const TouchGridTestPage({super.key});

  @override
  State<TouchGridTestPage> createState() => _TouchGridTestPageState();
}

class _TouchGridTestPageState extends State<TouchGridTestPage> {
  final Set<int> _hit = <int>{};

  // Lưu layout hiện tại để dùng ngoài build
  int _rows = 0, _cols = 0, _total = 0;
  double _cellSize = 0;

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

  void _markAtLocal(Offset localPosition) {
    _onUserInteraction();

    final r = (localPosition.dy / _cellSize).floor().clamp(0, _rows - 1);
    final c = (localPosition.dx / _cellSize).floor().clamp(0, _cols - 1);
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

        // Tính số cột/hàng để ô vuông vừa phải (khoảng 60-80px)
        // Ưu tiên 6 cột cho màn hình dọc, tự động tính hàng
        _cols = 6;
        _cellSize = fullW / _cols;
        _rows = (fullH / _cellSize).floor();
        _total = _rows * _cols;

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
                  final on = _hit.contains(i);
                  return Container(
                    decoration: BoxDecoration(
                      color: on ? Colors.green.shade400 : Colors.blue.shade900,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child:
                        on
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.white,
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
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ: ${_hit.length}/$_total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(_hit.length / _total * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Overlay đếm ngược khi idle
            if (_isFinalizing)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withValues(alpha: 0.5),
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
