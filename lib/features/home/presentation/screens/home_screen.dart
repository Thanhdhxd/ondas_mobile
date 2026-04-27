import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/features/home/domain/entities/album_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/artist_summary.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ondas_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:ondas_mobile/features/home/presentation/widgets/featured_artist_card_widget.dart';
import 'package:ondas_mobile/features/home/presentation/widgets/home_section_widget.dart';
import 'package:ondas_mobile/features/home/presentation/widgets/new_release_card_widget.dart';
import 'package:ondas_mobile/features/home/presentation/widgets/trending_song_card_widget.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';

Song _summaryToSong(SongSummary s) => Song(
      id: s.id,
      title: s.title,
      artistNames: s.artists.map((a) => a.name).toList(),
      coverUrl: s.coverUrl,
      audioUrl: s.audioUrl,
      durationSeconds: s.durationSeconds,
    );

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => sl<HomeBloc>()..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const _LoadingView(),
          HomeFailure(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<HomeBloc>().add(const HomeRefreshRequested()),
            ),
          HomeLoaded(:final data) => _ContentView(
              trendingSongs: data.trendingSongs,
              featuredArtists: data.featuredArtists,
              newReleases: data.newReleases,
              onRefresh: () async =>
                  context.read<HomeBloc>().add(const HomeRefreshRequested()),
            ),
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
    return const Center(
      child: CircularProgressIndicator(color: AppColors.spotifyGreen),
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
            style: const TextStyle(color: AppColors.silver),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          TextButton(
            key: const Key('homeScreen_retryButton'),
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: AppColors.spotifyGreen)),
          ),
        ],
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final List<SongSummary> trendingSongs;
  final List<ArtistSummary> featuredArtists;
  final List<AlbumSummary> newReleases;
  final Future<void> Function() onRefresh;

  const _ContentView({
    required this.trendingSongs,
    required this.featuredArtists,
    required this.newReleases,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.spotifyGreen,
      backgroundColor: AppColors.darkSurface,
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          const _HomeAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trendingSongs.isNotEmpty) ...[
                    HomeSectionWidget(
                      title: 'Trending',
                      child: _TrendingSongsList(songs: trendingSongs),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  if (featuredArtists.isNotEmpty) ...[
                    HomeSectionWidget(
                      title: 'Featured Artists',
                      child: _FeaturedArtistsList(artists: featuredArtists),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  if (newReleases.isNotEmpty) ...[
                    HomeSectionWidget(
                      title: 'New Releases',
                      child: _NewReleasesList(albums: newReleases),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AppColors.nearBlack,
      title: const Text(
        'Ondas',
        style: TextStyle(
          color: AppColors.spotifyGreen,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrendingSongsList extends StatelessWidget {
  final List<SongSummary> songs;

  const _TrendingSongsList({required this.songs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: ListView.separated(
        key: const Key('homeScreen_trendingList'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => TrendingSongCardWidget(
          key: Key('homeScreen_trendingSong_$index'),
          song: songs[index],
          onTap: () {
            final queue = songs.map(_summaryToSong).toList();
            context.read<PlayerBloc>().add(
              PlaySongRequested(songs: queue, index: index),
            );
          },
        ),
      ),
    );
  }
}

class _FeaturedArtistsList extends StatelessWidget {
  final List<ArtistSummary> artists;

  const _FeaturedArtistsList({required this.artists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        key: const Key('homeScreen_artistsList'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.base),
        itemBuilder: (context, index) => FeaturedArtistCardWidget(
          key: Key('homeScreen_featuredArtist_$index'),
          artist: artists[index],
        ),
      ),
    );
  }
}

class _NewReleasesList extends StatelessWidget {
  final List<AlbumSummary> albums;

  const _NewReleasesList({required this.albums});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: ListView.separated(
        key: const Key('homeScreen_newReleasesList'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: albums.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => NewReleaseCardWidget(
          key: Key('homeScreen_newRelease_$index'),
          album: albums[index],
        ),
      ),
    );
  }
}
