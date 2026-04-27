import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_bloc.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_state.dart';
import 'package:ondas_mobile/features/playlist/presentation/widgets/playlist_song_tile_widget.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';

Song _toSong(PlaylistSongItem item) => Song(
      id: item.song.id,
      title: item.song.title,
      artistNames: item.song.artists.map((a) => a.name).toList(),
      coverUrl: item.song.coverUrl,
      audioUrl: item.song.audioUrl,
      durationSeconds: item.song.durationSeconds,
    );

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlaylistDetailBloc>(
      create: (_) => sl<PlaylistDetailBloc>()
        ..add(PlaylistDetailLoadRequested(playlistId)),
      child: const _PlaylistDetailView(),
    );
  }
}

class _PlaylistDetailView extends StatelessWidget {
  const _PlaylistDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
        builder: (context, state) => switch (state) {
          PlaylistDetailLoading() => const _LoadingView(),
          PlaylistDetailFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () => context
                  .read<PlaylistDetailBloc>()
                  .add(const PlaylistDetailRefreshRequested()),
            ),
          PlaylistDetailLoaded(:final playlist) =>
            _ContentView(playlist: playlist),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.spotifyGreen),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(backgroundColor: AppColors.nearBlack),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.negativeRed, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(color: AppColors.silver),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.base),
            TextButton(
              key: const Key('playlistDetail_retryButton'),
              onPressed: onRetry,
              child: const Text(
                'Thử lại',
                style: TextStyle(color: AppColors.spotifyGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final Playlist playlist;

  const _ContentView({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.spotifyGreen,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () async => context
          .read<PlaylistDetailBloc>()
          .add(const PlaylistDetailRefreshRequested()),
      child: CustomScrollView(
        slivers: [
          _PlaylistSliverHeader(playlist: playlist),
          if (playlist.songs.isEmpty)
            const SliverFillRemaining(child: _EmptySongsView())
          else
            SliverList.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final item = playlist.songs[index];
                return PlaylistSongTileWidget(
                  key: Key('playlistDetail_songTile_$index'),
                  item: item,
                  onTap: () {
                    final queue =
                        playlist.songs.map(_toSong).toList();
                    context.read<PlayerBloc>().add(
                          PlaySongRequested(
                            songs: queue,
                            index: index,
                            source: 'playlist',
                          ),
                        );
                  },
                  onRemove: () => context
                      .read<PlaylistDetailBloc>()
                      .add(PlaylistDetailSongRemoveRequested(item.song.id)),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PlaylistSliverHeader extends StatelessWidget {
  final Playlist playlist;

  const _PlaylistSliverHeader({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.nearBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(playlist: playlist),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _PlayAllBar(playlist: playlist),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final Playlist playlist;

  const _HeaderBackground({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (playlist.coverUrl != null)
          Image.network(
            playlist.coverUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallbackCover,
          )
        else
          _fallbackCover,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.nearBlack.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.base,
          bottom: 60,
          right: AppSpacing.base,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (playlist.description != null &&
                  playlist.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  playlist.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.silver,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
                    const Icon(Icons.lock_outline,
                        size: 12, color: AppColors.silver),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _fallbackCover => Container(
        color: AppColors.darkSurface,
        child: const Icon(
          Icons.queue_music,
          color: AppColors.silver,
          size: 64,
        ),
      );
}

class _PlayAllBar extends StatelessWidget {
  final Playlist playlist;

  const _PlayAllBar({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.nearBlack,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      height: 48,
      child: Row(
        children: [
          ElevatedButton.icon(
            key: const Key('playlistDetail_playAllButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spotifyGreen,
              foregroundColor: AppColors.nearBlack,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            ),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Phát tất cả'),
            onPressed: playlist.songs.isEmpty
                ? null
                : () {
                    final queue = playlist.songs.map(_toSong).toList();
                    context.read<PlayerBloc>().add(
                          PlaySongRequested(
                            songs: queue,
                            index: 0,
                            source: 'playlist',
                          ),
                        );
                  },
          ),
        ],
      ),
    );
  }
}

class _EmptySongsView extends StatelessWidget {
  const _EmptySongsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off, color: AppColors.silver, size: 48),
          SizedBox(height: AppSpacing.md),
          Text(
            'Playlist chưa có bài hát nào',
            style: TextStyle(color: AppColors.silver),
          ),
        ],
      ),
    );
  }
}
