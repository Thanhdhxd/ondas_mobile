import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/library_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class LibraryPlaylistItemWidget extends StatelessWidget {
  final PlaylistSummary playlist;

  const LibraryPlaylistItemWidget({super.key, required this.playlist});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Playlist',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: const TextStyle(color: AppColors.silver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.silver)),
          ),
          TextButton(
            key: const Key('deletePlaylistDialog_confirmButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.negativeRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<LibraryBloc>()
          .add(LibraryPlaylistDeleteRequested(playlist.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('libraryPlaylistItem_${playlist.id}'),
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
      trailing: PopupMenuButton<_PlaylistAction>(
        key: ValueKey('libraryPlaylistMenu_${playlist.id}'),
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.silver),
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (action) {
          if (action == _PlaylistAction.delete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) _confirmDelete(context);
            });
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: _PlaylistAction.delete,
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: AppColors.negativeRed, size: 20),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: AppColors.negativeRed)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => context.push(
        '/library/playlist/${playlist.id}',
        extra: playlist,
      ),
    );
  }
}

enum _PlaylistAction { delete }

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
