import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_song_tile_widget.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_bloc.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_event.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_state.dart';

class SongListRouteData {
  final String? artistId;
  final String? albumId;
  final String title;
  final String? coverUrl;

  const SongListRouteData({
    this.artistId,
    this.albumId,
    required this.title,
    this.coverUrl,
  });
}

class SongListScreen extends StatelessWidget {
  final SongListRouteData routeData;

  const SongListScreen({super.key, required this.routeData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SongListBloc>(
      create: (_) => sl<SongListBloc>()
        ..add(SongListStarted(
          artistId: routeData.artistId,
          albumId: routeData.albumId,
        )),
      child: _SongListView(routeData: routeData),
    );
  }
}

class _SongListView extends StatefulWidget {
  final SongListRouteData routeData;

  const _SongListView({required this.routeData});

  @override
  State<_SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<_SongListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SongListBloc>().add(const SongListLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('songListScreen_scaffold'),
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        elevation: 0,
        leading: IconButton(
          key: const Key('songListScreen_backButton'),
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.routeData.title,
          style: AppTypography.bodyBold.copyWith(color: AppColors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocBuilder<SongListBloc, SongListState>(
        builder: (context, state) => switch (state) {
          SongListInitial() || SongListLoading() => const _LoadingView(),
          SongListLoaded(
            :final songs,
            hasMore: _,
          ) =>
            _SongsList(
              songs: songs,
              isLoadingMore: state is SongListLoadingMore,
              scrollController: _scrollController,
            ),
          SongListFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<SongListBloc>().add(SongListStarted(
                    artistId: widget.routeData.artistId,
                    albumId: widget.routeData.albumId,
                  )),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _SongsList extends StatelessWidget {
  final List<SongSummary> songs;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const _SongsList({
    required this.songs,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      key: const Key('songListScreen_list'),
      controller: scrollController,
      itemCount: songs.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= songs.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.spotifyGreen),
            ),
          );
        }
        final song = songs[index];
        return SearchSongTileWidget(
          key: Key('songListScreen_songTile_${song.id}'),
          song: song,
          onTap: () {
            final queue = songs
                .map((s) => Song(
                      id: s.id,
                      title: s.title,
                      artistNames: s.artists.map((a) => a.name).toList(),
                      coverUrl: s.coverUrl,
                      audioUrl: s.audioUrl,
                      durationSeconds: s.durationSeconds,
                    ))
                .toList();
            context.read<PlayerBloc>().add(PlaySongRequested(
                  songs: queue,
                  index: index,
                ));
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.spotifyGreen),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off, color: AppColors.silver, size: 64),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Không có bài hát nào',
            style: AppTypography.body.copyWith(color: AppColors.silver),
          ),
        ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.negativeRed, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.silver),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          TextButton(
            key: const Key('songListScreen_retryButton'),
            onPressed: onRetry,
            child: const Text(
              'Thử lại',
              style: TextStyle(color: AppColors.spotifyGreen),
            ),
          ),
        ],
      ),
    );
  }
}
