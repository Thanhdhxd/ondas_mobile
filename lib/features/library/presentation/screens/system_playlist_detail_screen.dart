import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/library/presentation/bloc/system_playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';

class SystemPlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  final String initialName;

  const SystemPlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.initialName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: BlocBuilder<SystemPlaylistDetailBloc, SystemPlaylistDetailState>(
        builder: (context, state) => switch (state) {
          SystemPlaylistDetailInitial() || SystemPlaylistDetailLoading() =>
            _buildLoadingScaffold(context),
          SystemPlaylistDetailError(:final message) =>
            _buildErrorScaffold(context, message),
          SystemPlaylistDetailLoaded(:final detail) =>
            _buildLoadedScaffold(context, detail),
        },
      ),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, initialName),
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
        _buildAppBar(context, initialName),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context
                      .read<SystemPlaylistDetailBloc>()
                      .add(SystemPlaylistDetailStarted(playlistId)),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(color: AppColors.spotifyGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedScaffold(BuildContext context, PlaylistDetail detail) {
    final songs = detail.songs;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, detail.name),
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
                    style: TextStyle(color: AppColors.silver, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return _SongTile(
                  song: song,
                  onTap: () {
                    final queue = songs
                        .map(
                          (s) => Song(
                            id: s.songId,
                            title: s.title,
                            artistNames: s.artistNames,
                            coverUrl: s.coverUrl,
                            audioUrl: s.audioUrl,
                            durationSeconds: s.durationSeconds,
                          ),
                        )
                        .toList();
                    context.read<PlayerBloc>().add(
                          PlaySongRequested(
                            songs: queue,
                            index: index,
                            source: 'system_playlist',
                          ),
                        );
                    context.push('/player');
                  },
                );
              },
              childCount: songs.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String name) {
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
    );
  }
}

class _SongTile extends StatelessWidget {
  final PlaylistSongItem song;
  final VoidCallback onTap;

  const _SongTile({required this.song, required this.onTap});

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
      trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.spotifyGreen),
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
