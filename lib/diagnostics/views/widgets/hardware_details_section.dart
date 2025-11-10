import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auto_diagnostics_controller.dart';

/// Hardware Details Section - Displays camera and sensor information
class HardwareDetailsSection extends StatelessWidget {
  const HardwareDetailsSection({super.key, required this.controller});

  final AutoDiagnosticsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hardware Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Camera System Expandable
          HardwareExpandable(
            title: 'Camera System',
            icon: Icons.camera_alt,
            children: [
              Obx(() {
                final cameraSpecs = controller.info['camera_specs'] as Map? ?? {};
                final total = cameraSpecs['total'] ?? 0;
                final front = cameraSpecs['front'] ?? 0;
                final back = cameraSpecs['back'] ?? 0;
                final cameras = (cameraSpecs['cameras'] as List?) ?? [];

                if (total == 0) {
                  return const HardwareDetailRow(
                    icon: Icons.camera_alt,
                    label: 'Cameras',
                    value: 'No camera detected',
                    isWorking: false,
                  );
                }

                return Column(
                  children: [
                    // Summary
                    HardwareDetailRow(
                      icon: Icons.camera_alt,
                      label: 'Total Cameras',
                      value: '$total camera${total > 1 ? 's' : ''}',
                      isWorking: true,
                    ),

                    // Front cameras
                    if (front > 0)
                      HardwareDetailRow(
                        icon: Icons.camera_front,
                        label: 'Front Camera${front > 1 ? 's' : ''}',
                        value: '$front camera${front > 1 ? 's' : ''}',
                      ),

                    // Back cameras
                    if (back > 0)
                      HardwareDetailRow(
                        icon: Icons.camera_rear,
                        label: 'Back Camera${back > 1 ? 's' : ''}',
                        value: '$back camera${back > 1 ? 's' : ''}',
                      ),

                    // Individual cameras
                    ...cameras.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cam = entry.value as Map;
                      final name = cam['name'] ?? 'Camera $idx';
                      final direction = cam['direction'] ?? 'unknown';

                      // Identify camera type from name
                      String cameraType = 'Camera';
                      IconData cameraIcon = Icons.camera;

                      final nameLower = name.toString().toLowerCase();
                      if (nameLower.contains('ultra') || nameLower.contains('wide')) {
                        cameraType = 'Ultra-wide';
                        cameraIcon = Icons.aspect_ratio;
                      } else if (nameLower.contains('tele') || nameLower.contains('zoom')) {
                        cameraType = 'Telephoto';
                        cameraIcon = Icons.zoom_in;
                      } else if (nameLower.contains('macro')) {
                        cameraType = 'Macro';
                        cameraIcon = Icons.filter_center_focus;
                      } else if (direction == 'front') {
                        cameraType = 'Selfie';
                        cameraIcon = Icons.face;
                      } else if (direction == 'back') {
                        cameraType = 'Main';
                        cameraIcon = Icons.camera_rear;
                      }

                      return HardwareDetailRow(
                        icon: cameraIcon,
                        label: cameraType,
                        value: name,
                      );
                    }).toList(),
                  ],
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Sensors Expandable
          HardwareExpandable(
            title: 'Sensors',
            icon: Icons.sensors,
            children: [
              Obx(() {
                final sensorsInfo = controller.info['sensors'] as Map? ?? {};
                final hasAccel = sensorsInfo['accelerometer'] == true;
                final hasGyro = sensorsInfo['gyroscope'] == true;

                return Column(
                  children: [
                    HardwareDetailRow(
                      icon: Icons.navigation,
                      label: 'Accelerometer',
                      value: hasAccel ? 'Working' : 'Not detected',
                      isWorking: hasAccel,
                    ),
                    HardwareDetailRow(
                      icon: Icons.screen_rotation,
                      label: 'Gyroscope',
                      value: hasGyro ? 'Working' : 'Not detected',
                      isWorking: hasGyro,
                    ),
                    const HardwareDetailRow(
                      icon: Icons.my_location,
                      label: 'GPS',
                      value: 'Multi-constellation',
                    ),
                    const HardwareDetailRow(
                      icon: Icons.light_mode,
                      label: 'Ambient Light',
                      value: 'Available',
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hardware Expandable Widget
class HardwareExpandable extends StatefulWidget {
  const HardwareExpandable({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  State<HardwareExpandable> createState() => _HardwareExpandableState();
}

class _HardwareExpandableState extends State<HardwareExpandable> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.children,
              ),
            ),
        ],
      ),
    );
  }
}

/// Hardware Detail Row Widget
class HardwareDetailRow extends StatelessWidget {
  const HardwareDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isWorking,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool? isWorking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (isWorking != null)
            Icon(
              isWorking! ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: isWorking! ? Colors.green : Colors.red,
            ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

