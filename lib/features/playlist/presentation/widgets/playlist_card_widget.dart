import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

class PlaylistCardWidget extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCardWidget({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.comfortable),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.comfortable),
        ),
        child: Row(
          children: [
            _CoverImage(coverUrl: playlist.coverUrl),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          '${playlist.totalSongs} bài hát',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.silver,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (!playlist.isPublic)
                          Icon(
                            Icons.lock_outline,
                            size: 12,
                            color: AppColors.silver,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.silver,
              ),
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
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(AppRadius.comfortable),
      ),
      child: SizedBox(
        width: 72,
        height: 72,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder,
              )
            : _placeholder,
      ),
    );
  }

  Widget get _placeholder => Container(
        color: AppColors.midCard,
        child: const Icon(
          Icons.queue_music,
          color: AppColors.silver,
          size: 32,
        ),
      );
}
