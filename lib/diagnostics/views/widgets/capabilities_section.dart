import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auto_diagnostics_controller.dart';

/// Capabilities Section - Shows device capabilities like NFC, Bio, S-Pen
class CapabilitiesSection extends StatelessWidget {
  const CapabilitiesSection({super.key, required this.controller});

  final AutoDiagnosticsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capabilities',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final info = controller.info;
            final nfcAvailable = (info['nfc'] as Map?)?['available'] == true;
            final bioSupported = (info['bio'] as Map?)?['supported'] == true;
            final spenSupported = controller.isSamsung && (info['spen'] == true);

            // RAM/ROM info
            final ram = (info['ram'] as Map?)?.cast<String, dynamic>() ?? {};
            final rom = (info['rom'] as Map?)?.cast<String, dynamic>() ?? {};
            final ramGb = _toGiB(ram['totalBytes']);
            final romGb = _toGiB(rom['totalBytes']);
            final romFreeGb = _toGiB(rom['freeBytes']);

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // RAM
                if (ramGb != null)
                  CapabilityChip(
                    icon: Icons.memory,
                    label: 'RAM',
                    sublabel: '$ramGb GB',
                    isEnabled: true,
                  ),

                // ROM/Storage
                if (romGb != null)
                  CapabilityChip(
                    icon: Icons.storage,
                    label: 'Storage',
                    sublabel: romFreeGb != null
                        ? '$romFreeGb GB free / $romGb GB'
                        : '$romGb GB',
                    isEnabled: true,
                  ),

                CapabilityChip(
                  icon: Icons.nfc,
                  label: 'NFC',
                  sublabel: nfcAvailable ? 'Enabled' : 'Not Available',
                  isEnabled: nfcAvailable,
                ),
                CapabilityChip(
                  icon: Icons.fingerprint,
                  label: 'Fingerprint Sensor',
                  sublabel: bioSupported ? 'Available' : 'Not Available',
                  isEnabled: bioSupported,
                ),
                if (spenSupported)
                  const CapabilityChip(
                    icon: Icons.edit,
                    label: 'S-Pen',
                    sublabel: 'Supported',
                    isEnabled: true,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  int? _toGiB(dynamic v) {
    if (v is! num) return null;
    const giB = 1024 * 1024 * 1024;
    return (v.toDouble() / giB).round();
  }
}

/// Capability Chip Widget
class CapabilityChip extends StatelessWidget {
  const CapabilityChip({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isEnabled,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

