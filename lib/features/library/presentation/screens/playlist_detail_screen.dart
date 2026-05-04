import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/library/presentation/widgets/edit_playlist_dialog.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String initialName;

  const PlaylistDetailScreen({super.key, required this.initialName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
        builder: (context, state) => switch (state) {
          PlaylistDetailInitial() || PlaylistDetailLoading() =>
            _buildLoadingScaffold(context),
          PlaylistDetailError(:final message) =>
            _buildErrorScaffold(context, message),
          PlaylistDetailLoaded(:final detail) =>
            _buildLoadedScaffold(context, detail.name, detail),
        },
      ),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, initialName, null),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.spotifyGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, initialName, null),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.negativeRed, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Không thể tải playlist',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context
                      .read<PlaylistDetailBloc>()
                      .add(PlaylistDetailStarted(
                        (context.read<PlaylistDetailBloc>().state
                                as PlaylistDetailError)
                            .message,
                      )),
                  child: const Text('Thử lại',
                      style: TextStyle(color: AppColors.spotifyGreen)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScaffold(
      BuildContext context, String name, dynamic detail) {
    final songs = detail.songs as List<PlaylistSongItem>;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, name, detail),
        if (songs.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note_rounded,
                      color: AppColors.silver, size: 56),
                  SizedBox(height: 12),
                  Text(
                    'Playlist này chưa có bài hát',
                    style:
                        TextStyle(color: AppColors.silver, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          SliverReorderableList(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Material(
                key: ValueKey(song.songId),
                color: AppColors.nearBlack,
                child: ReorderableDragStartListener(
                  index: index,
                  child: _PlaylistSongItemWidget(
                    song: song,                    onTap: () {
                      final queue = songs
                          .map((s) => Song(
                                id: s.songId,
                                title: s.title,
                                artistNames: s.artistNames,
                                coverUrl: s.coverUrl,
                                audioUrl: s.audioUrl,
                                durationSeconds: s.durationSeconds,
                              ))
                          .toList();
                      context.read<PlayerBloc>().add(
                            PlaySongRequested(
                              songs: queue,
                              index: index,
                              source: 'playlist',
                            ),
                          );
                    },                    onRemove: () => context
                        .read<PlaylistDetailBloc>()
                        .add(PlaylistDetailSongRemoved(song.songId)),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final newOrder = List<String>.from(
                songs.map((s) => s.songId),
              );
              final moved = newOrder.removeAt(oldIndex);
              newOrder.insert(newIndex, moved);
              context
                  .read<PlaylistDetailBloc>()
                  .add(PlaylistDetailReordered(newOrder));
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, String name, dynamic detail) {
    return SliverAppBar(
      backgroundColor: AppColors.nearBlack,
      foregroundColor: AppColors.white,
      floating: true,
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        if (detail != null)
          IconButton(
            key: const Key('playlistDetailScreen_editButton'),
            icon: const Icon(Icons.edit_outlined, color: AppColors.white),
            onPressed: () async {
              final newName = await showDialog<String>(
                context: context,
                builder: (_) =>
                    EditPlaylistDialog(initialName: detail.name as String),
              );
              if (newName != null &&
                  newName.isNotEmpty &&
                  newName != detail.name &&
                  context.mounted) {
                context
                    .read<PlaylistDetailBloc>()
                    .add(PlaylistDetailNameUpdated(newName));
              }
            },
          ),
      ],
    );
  }
}

class _PlaylistSongItemWidget extends StatelessWidget {
  final PlaylistSongItem song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistSongItemWidget({
    required this.song,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 48,
          height: 48,
          child: song.coverUrl != null
              ? Image.network(
                  song.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _FallbackCover(),
                )
              : const _FallbackCover(),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.durationDisplay,
        style: const TextStyle(color: AppColors.silver, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: AppColors.silver, size: 22),
            onPressed: onRemove,
            tooltip: 'Remove from playlist',
          ),
          const Icon(Icons.drag_handle_rounded,
              color: AppColors.silver, size: 22),
        ],
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
      child: Icon(Icons.music_note_rounded, color: AppColors.silver, size: 22),
    );
  }
}
