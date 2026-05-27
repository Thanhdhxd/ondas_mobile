import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;

  const ProfileMenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedIconColor = iconColor ?? AppColors.silver;
    final resolvedLabelColor = labelColor ?? AppColors.white;

    final resolvedTrailing = trailing ??
        (showChevron
            ? const Icon(Icons.chevron_right, color: AppColors.silver)
            : null);

    return ListTile(
      leading: Icon(icon, color: resolvedIconColor),
      title: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(color: resolvedLabelColor),
      ),
      trailing: resolvedTrailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
