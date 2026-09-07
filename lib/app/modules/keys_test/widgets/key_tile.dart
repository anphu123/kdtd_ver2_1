import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';

/// Một dòng hiển thị trạng thái 1 phím vật lý (đã nhận/chưa nhận/thất bại).
class KeyTile extends StatelessWidget {
  final String label;
  final bool active;
  final bool failed;
  final IconData icon;
  final VoidCallback action;

  const KeyTile({
    super.key,
    required this.label,
    required this.active,
    required this.icon,
    required this.action,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = active ? 'Đã nhận' : (failed ? 'Không nhận (Thất bại)' : 'Chưa nhận');

    final Color? bg = active ? AppColors.neutralGreyLight : null;
    final Color? iconColor = active ? Theme.of(context).colorScheme.primary : null;

    return Card(
      elevation: 0,
      color: bg,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label),
        subtitle: Text(
          subtitle,
          style: failed ? AppTextStyles.bodySmall.copyWith(color: AppColors.fail) : null,
        ),
        trailing: TextButton(
          onPressed: action,
          child: const Text('Đánh dấu'),
        ),
      ),
    );
  }
}
