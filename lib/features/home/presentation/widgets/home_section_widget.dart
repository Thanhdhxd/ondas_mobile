import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';

class HomeSectionWidget extends StatelessWidget {
  final String title;
  final Widget child;

  const HomeSectionWidget({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            title,
            style: AppTypography.featureHeading.copyWith(color: AppColors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}
