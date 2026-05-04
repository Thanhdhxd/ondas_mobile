import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';

class SearchSectionHeaderWidget extends StatelessWidget {
  final String title;
  final int total;

  const SearchSectionHeaderWidget({
    super.key,
    required this.title,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.featureHeading.copyWith(color: AppColors.white),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($total)',
            style: AppTypography.caption.copyWith(color: AppColors.silver),
          ),
        ],
      ),
    );
  }
}
