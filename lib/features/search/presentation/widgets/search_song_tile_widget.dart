import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class SearchSongTileWidget extends StatelessWidget {
  final SongSummary song;
  final VoidCallback? onTap;

  const SearchSongTileWidget({
    super.key,
    required this.song,
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
      leading: _CoverImage(coverUrl: song.coverUrl),
      title: Text(
        song.title,
        style: AppTypography.bodyBold.copyWith(color: AppColors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artists.map((a) => a.name).join(', '),
        style: AppTypography.caption.copyWith(color: AppColors.silver),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? coverUrl;

  const _CoverImage({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.subtle),
      child: SizedBox(
        width: 48,
        height: 48,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
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
      child: const Icon(Icons.music_note, color: AppColors.silver, size: 24),
    );
  }
}
