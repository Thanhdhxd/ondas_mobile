import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const ProfileMenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedIconColor = iconColor ?? AppColors.silver;
    final resolvedLabelColor = labelColor ?? AppColors.white;

    return ListTile(
      leading: Icon(icon, color: resolvedIconColor),
      title: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(color: resolvedLabelColor),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.silver),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
