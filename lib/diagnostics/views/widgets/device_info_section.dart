import 'package:flutter/material.dart';

/// Device Info Section - Displays device information and progress
class DeviceInfoSection extends StatelessWidget {
  const DeviceInfoSection({
    super.key,
    required this.modelName,
    required this.brand,
    required this.manufacturer,
    required this.platform,
    required this.progress,
    required this.completed,
    required this.total,
  });

  final String modelName;
  final String brand;
  final String manufacturer;
  final String platform;
  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Phone Preview
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Phone Device Mockup
                Container(
                  width: 120,
                  height: 140,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Screen
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.smartphone_rounded,
                                size: 48,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Notch
                      Positioned(
                        top: 8,
                        left: 40,
                        right: 40,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Model Name
                Text(
                  modelName.isNotEmpty && modelName != '-' ? modelName : 'Unknown Device',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Brand/Series
                // Text(
                //   brand.isNotEmpty && brand != '-' ? '$brand Series' : platform,
                //   textAlign: TextAlign.center,
                //   style: theme.textTheme.bodySmall?.copyWith(
                //     color: theme.colorScheme.onSurface.withOpacity(0.6),
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Right: Progress Circle
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Circular Progress
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 12,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      // Progress circle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      // Center text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Overall Progress Label
                Text(
                  'Overall Progress',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

