import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';

class PlayerInfoWidget extends StatelessWidget {
  final String songTitle;
  final String artistDisplay;

  const PlayerInfoWidget({
    super.key,
    required this.songTitle,
    required this.artistDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          songTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          artistDisplay,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.silver,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
