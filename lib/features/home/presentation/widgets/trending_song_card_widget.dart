import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class TrendingSongCardWidget extends StatelessWidget {
  final SongSummary song;
  final VoidCallback? onTap;

  const TrendingSongCardWidget({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(coverUrl: song.coverUrl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: _SongInfo(song: song),
            ),
          ],
        ),
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
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.comfortable),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) {
                  debugPrint('[TrendingSong] Image failed: $coverUrl — $error');
                  return const _PlaceholderCover();
                },
              )
            : (() {
                debugPrint('[TrendingSong] coverUrl is null');
                return const _PlaceholderCover();
              })(),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midCard,
      child: const Icon(Icons.music_note, color: AppColors.silver, size: 40),
    );
  }
}

class _SongInfo extends StatelessWidget {
  final SongSummary song;

  const _SongInfo({required this.song});

  @override
  Widget build(BuildContext context) {
    final artistNames = song.artists.map((a) => a.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: AppTypography.captionBold.copyWith(color: AppColors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          artistNames,
          style: AppTypography.caption.copyWith(color: AppColors.silver),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
