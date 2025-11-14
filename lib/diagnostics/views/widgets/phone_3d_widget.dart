import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget hiển thị điện thoại 3D với animation xoay
/// Hỗ trợ cả hình ảnh thực và render 3D
class Phone3DWidget extends StatefulWidget {
  final int score;
  final String modelName;
  final String brand;
  final Color color;
  final String? imageAsset;
  final bool useRealImage;

  const Phone3DWidget({
    super.key,
    required this.score,
    required this.modelName,
    required this.brand,
    required this.color,
    this.imageAsset,
    this.useRealImage = true,
  });

  @override
  State<Phone3DWidget> createState() => _Phone3DWidgetState();
}

class _Phone3DWidgetState extends State<Phone3DWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotationY += details.delta.dx * 0.01;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final autoRotation = _controller.value * 2 * math.pi;
          final totalRotation = _rotationY + autoRotation;

          return Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(totalRotation)
                  ..rotateX(-0.2),
            alignment: Alignment.center,
            child: Container(
              width: 200,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Screen
                  Positioned(
                    top: 20,
                    left: 10,
                    right: 10,
                    bottom: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getScoreIcon(widget.score),
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.score}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.modelName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Notch
                  Positioned(
                    top: 15,
                    left: 70,
                    right: 70,
                    child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Camera bump (back)
                  if (math.cos(totalRotation) < 0)
                    Positioned(
                      top: 30,
                      left: 20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [_buildCamera(12), _buildCamera(12)],
                            ),
                            _buildCamera(16),
                          ],
                        ),
                      ),
                    ),

                  // Side buttons
                  Positioned(
                    right: -5,
                    top: 100,
                    child: Container(
                      width: 5,
                      height: 60,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -5,
                    top: 180,
                    child: Container(
                      width: 5,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCamera(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 80) return Icons.star;
    if (score >= 70) return Icons.thumb_up;
    if (score >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }
}
