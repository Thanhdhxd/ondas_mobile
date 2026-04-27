import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';

class FeaturedArtistCardWidget extends StatelessWidget {
  final ArtistSummary artist;
  final VoidCallback? onTap;

  const FeaturedArtistCardWidget({
    super.key,
    required this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            _AvatarImage(avatarUrl: artist.avatarUrl),
            const SizedBox(height: AppSpacing.xs),
            Text(
              artist.name,
              style: AppTypography.caption.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String? avatarUrl;

  const _AvatarImage({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 80,
        height: 80,
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) {
                  debugPrint('[Artist] Image failed: $avatarUrl — $error');
                  return const _PlaceholderAvatar();
                },
              )
            : (() {
                debugPrint('[Artist] avatarUrl is null');
                return const _PlaceholderAvatar();
              })(),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midCard,
      child: const Icon(Icons.person, color: AppColors.silver, size: 36),
    );
  }
}
