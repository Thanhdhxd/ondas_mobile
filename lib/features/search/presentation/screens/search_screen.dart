import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/di/injection.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_album_tile_widget.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_artist_tile_widget.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_section_header_widget.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_song_tile_widget.dart';
import 'package:ondas_mobile/features/search/presentation/widgets/search_suggestion_view.dart';
import 'package:ondas_mobile/features/songs/presentation/screens/song_list_screen.dart';

Song _summaryToSong(SongSummary s) => Song(
      id: s.id,
      title: s.title,
      artistNames: s.artists.map((a) => a.name).toList(),
      coverUrl: s.coverUrl,
      audioUrl: s.audioUrl,
      durationSeconds: s.durationSeconds,
    );

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => sl<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SuggestionsRequested());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<SearchBloc>().add(const SearchCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchBloc>().add(SearchSubmitted(value.trim()));
      }
    });
  }

  void _submitSearchImmediately(String query) {
    _debounce?.cancel();
    _controller.text = query;
    context.read<SearchBloc>().add(SearchSubmitted(query));
  }

  void _clearSearch() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('searchScreen_scaffold'),
      backgroundColor: AppColors.nearBlack,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _controller,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
            Expanded(
              child: _SearchBody(
                onSearchTapped: _submitSearchImmediately,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: TextField(
        key: const Key('searchScreen_searchField'),
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.body.copyWith(color: AppColors.white),
        cursorColor: AppColors.spotifyGreen,
        decoration: InputDecoration(
          hintText: 'Tìm bài hát, nghệ sĩ, album...',
          hintStyle: AppTypography.body.copyWith(color: AppColors.silver),
          prefixIcon: const Icon(Icons.search, color: AppColors.silver),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                key: const Key('searchScreen_clearButton'),
                icon: const Icon(Icons.close, color: AppColors.silver),
                onPressed: onClear,
              );
            },
          ),
          filled: true,
          fillColor: AppColors.midDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.fullPill),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.fullPill),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.fullPill),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.base,
          ),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  final ValueChanged<String> onSearchTapped;

  const _SearchBody({required this.onSearchTapped});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) => switch (state) {
        SearchInitial() => const _LoadingView(),
        SearchSuggestionsLoading() => const _LoadingView(),
        SearchSuggestionsLoaded(:final suggestion) => SearchSuggestionView(
            key: const Key('searchScreen_suggestions'),
            suggestion: suggestion,
            onSearchTapped: onSearchTapped,
          ),
        SearchLoading() => const _LoadingView(),
        SearchLoaded(
          :final songs,
          :final artists,
          :final albums,
          :final totalSongs,
          :final totalArtists,
          :final totalAlbums,
          :final query,
          :final hasMore,
        ) =>
          _ResultsView(
            query: query,
            songs: songs,
            artists: artists,
            albums: albums,
            totalSongs: totalSongs,
            totalArtists: totalArtists,
            totalAlbums: totalAlbums,
            hasMore: hasMore,
            isLoadingMore: state is SearchLoadingMore,
          ),
        SearchFailure(:final message) => _ErrorView(
            message: message,
            onRetry: () {
              final viewState =
                  context.findAncestorStateOfType<_SearchViewState>();
              final query = viewState?._controller.text.trim() ?? '';
              if (query.isNotEmpty) {
                context.read<SearchBloc>().add(SearchSubmitted(query));
              } else {
                context.read<SearchBloc>().add(const SuggestionsRequested());
              }
            },
          ),
        _ => const SizedBox.shrink(),
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
            key: const Key('searchScreen_retryButton'),
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

class _ResultsView extends StatelessWidget {
  final String query;
  final List songs;
  final List artists;
  final List albums;
  final int totalSongs;
  final int totalArtists;
  final int totalAlbums;
  final bool hasMore;
  final bool isLoadingMore;

  const _ResultsView({
    required this.query,
    required this.songs,
    required this.artists,
    required this.albums,
    required this.totalSongs,
    required this.totalArtists,
    required this.totalAlbums,
    required this.hasMore,
    required this.isLoadingMore,
  });

  bool get _isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return const _NoResultsView();

    return SingleChildScrollView(
      key: const Key('searchScreen_resultsList'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (songs.isNotEmpty) ...[
            SearchSectionHeaderWidget(title: 'Bài hát', total: totalSongs),
            _SectionList(
              children: songs.map(
                (song) => SearchSongTileWidget(
                  key: Key('searchScreen_songTile_${song.id}'),
                  song: song,
                  onTap: () {
                    final queue =
                        songs.map((s) => _summaryToSong(s as SongSummary)).toList();
                    final idx = songs.indexOf(song);
                    context.read<PlayerBloc>().add(PlaySongRequested(
                      songs: queue,
                      index: idx < 0 ? 0 : idx,
                    ));
                  },
                ),
              ).toList(),
            ),
          ],
          if (artists.isNotEmpty) ...[
            SearchSectionHeaderWidget(title: 'Nghệ sĩ', total: totalArtists),
            _SectionList(
              children: artists.map(
                (artist) => SearchArtistTileWidget(
                  key: Key('searchScreen_artistTile_${artist.id}'),
                  artist: artist,
                  onTap: () => context.push(
                    '/songs/artist/${artist.id}',
                    extra: SongListRouteData(
                      artistId: artist.id,
                      title: artist.name,
                      coverUrl: artist.avatarUrl,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
          if (albums.isNotEmpty) ...[
            SearchSectionHeaderWidget(title: 'Album', total: totalAlbums),
            _SectionList(
              children: albums.map(
                (album) => SearchAlbumTileWidget(
                  key: Key('searchScreen_albumTile_${album.id}'),
                  album: album,
                  onTap: () => context.push(
                    '/songs/album/${album.id}',
                    extra: SongListRouteData(
                      albumId: album.id,
                      title: album.title,
                      coverUrl: album.coverUrl,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.spotifyGreen),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionList extends StatefulWidget {
  final List<Widget> children;

  const _SectionList({required this.children});

  @override
  State<_SectionList> createState() => _SectionListState();
}

class _SectionListState extends State<_SectionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemHeight = 72.0;
    final maxVisible = 5;
    final height = (widget.children.length * itemHeight).clamp(0.0, itemHeight * maxVisible);

    return SizedBox(
      height: height,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          children: widget.children,
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off, color: AppColors.silver, size: 64),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Không tìm thấy kết quả',
            style: AppTypography.bodyBold.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Thử từ khóa khác',
            style: AppTypography.caption.copyWith(color: AppColors.silver),
          ),
        ],
      ),
    );
  }
}
