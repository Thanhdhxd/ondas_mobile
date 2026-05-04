import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';

/// Placeholder lyrics tab — will be connected to the Lyrics feature
/// once synced-lyrics data is available from the backend.
class PlayerLyricsTab extends StatelessWidget {
  const PlayerLyricsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lyrics_outlined, size: 64, color: AppColors.silver),
          SizedBox(height: AppSpacing.base),
          Text(
            'Lyrics not available',
            style: TextStyle(
              color: AppColors.silver,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Lyrics will appear here',
            style: TextStyle(
              color: AppColors.borderGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
