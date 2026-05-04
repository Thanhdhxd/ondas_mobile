import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';

class SearchArtistTileWidget extends StatelessWidget {
  final ArtistSummary artist;
  final VoidCallback? onTap;

  const SearchArtistTileWidget({
    super.key,
    required this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xxs,
      ),
      leading: _AvatarImage(avatarUrl: artist.avatarUrl),
      title: Text(
        artist.name,
        style: AppTypography.bodyBold.copyWith(color: AppColors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Artist',
        style: AppTypography.caption.copyWith(color: AppColors.silver),
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
        width: 48,
        height: 48,
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _Placeholder(),
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midCard,
      child: const Icon(Icons.person, color: AppColors.silver, size: 24),
    );
  }
}
