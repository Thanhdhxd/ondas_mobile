import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class SystemPlaylistItemWidget extends StatelessWidget {
  final PlaylistSummary playlist;

  const SystemPlaylistItemWidget({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('systemPlaylistItem_${playlist.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _PlaylistCover(coverUrl: playlist.coverUrl),
      title: Text(
        playlist.name,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.totalSongs} songs',
        style: const TextStyle(color: AppColors.silver, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.silver),
      onTap: () => context.push(
        '/library/system-playlist/${playlist.id}',
        extra: playlist,
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
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 52,
        height: 52,
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
      child: Icon(Icons.queue_music_rounded, color: AppColors.silver, size: 26),
    );
  }
}
