import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class PlaylistListTileWidget extends StatelessWidget {
  final PlaylistSummary playlist;
  final VoidCallback onToggle;

  const PlaylistListTileWidget({
    super.key,
    required this.playlist,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _PlaylistCover(coverUrl: playlist.coverUrl),
      title: Text(
        playlist.name,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.totalSongs} bài hát',
        style: const TextStyle(
          color: AppColors.silver,
          fontSize: 12,
        ),
      ),
      trailing: GestureDetector(
        onTap: onToggle,
        child: Icon(
          Icons.bookmark_border_rounded,
          color: playlist.containsSong
              ? AppColors.spotifyGreen
              : AppColors.silver,
          size: 28,
        ),
      ),
    );
  }
}

class _PlaylistCover extends StatelessWidget {
  final String? coverUrl;

  const _PlaylistCover({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 48,
        height: 48,
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _FallbackCover(),
              )
            : const _FallbackCover(),
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.darkSurface,
      child: Icon(Icons.queue_music_rounded, color: AppColors.silver, size: 24),
    );
  }
}
