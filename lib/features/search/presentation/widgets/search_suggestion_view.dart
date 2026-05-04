import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_radius.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';
import 'package:ondas_mobile/features/player/domain/entities/song.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_bloc.dart';
import 'package:ondas_mobile/features/player/presentation/bloc/player_event.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';

class SearchSuggestionView extends StatelessWidget {
  final SearchSuggestion suggestion;
  final ValueChanged<String> onSearchTapped;

  const SearchSuggestionView({
    super.key,
    required this.suggestion,
    required this.onSearchTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('searchScreen_suggestionsList'),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        if (suggestion.recentSearches.isNotEmpty)
          _RecentSearchesSection(
            searches: suggestion.recentSearches,
            onTap: onSearchTapped,
          ),
        if (suggestion.trendingSearches.isNotEmpty)
          _TrendingSearchesSection(
            searches: suggestion.trendingSearches,
            onTap: onSearchTapped,
          ),
        if (suggestion.trendingSongs.isNotEmpty)
          _TrendingSongsSection(trendingSongs: suggestion.trendingSongs),
        if (suggestion.genres.isNotEmpty)
          _GenresSection(genres: suggestion.genres, onSearchTapped: onSearchTapped),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recent Searches
// ---------------------------------------------------------------------------

class _RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;

  const _RecentSearchesSection({
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.lg,
            AppSpacing.base,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tìm kiếm gần đây',
                  style: AppTypography.featureHeading
                      .copyWith(color: AppColors.white),
                ),
              ),
              TextButton(
                key: const Key('searchScreen_clearHistoryButton'),
                onPressed: () =>
                    context.read<SearchBloc>().add(const SearchHistoryCleared()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Xóa tất cả',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.spotifyGreen),
                ),
              ),
            ],
          ),
        ),
        ...searches.map(
          (query) => ListTile(
            key: Key('searchScreen_recentItem_$query'),
            onTap: () => onTap(query),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xxs,
            ),
            leading: const Icon(Icons.history, color: AppColors.silver, size: 20),
            title: Text(
              query,
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
            trailing: const Icon(Icons.north_west,
                color: AppColors.silver, size: 16),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Trending Searches
// ---------------------------------------------------------------------------

class _TrendingSearchesSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;

  const _TrendingSearchesSection({
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.lg,
            AppSpacing.base,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up,
                  color: AppColors.spotifyGreen, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Trending',
                style: AppTypography.featureHeading
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: searches
                .map(
                  (query) => _SearchChip(
                    key: Key('searchScreen_trendingChip_$query'),
                    label: query,
                    onTap: () => onTap(query),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.midDark,
          borderRadius: BorderRadius.circular(AppRadius.fullPill),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trending Songs
// ---------------------------------------------------------------------------

class _TrendingSongsSection extends StatelessWidget {
  final List trendingSongs;

  const _TrendingSongsSection({required this.trendingSongs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.lg,
            AppSpacing.base,
            AppSpacing.xs,
          ),
          child: Text(
            'Bài hát nổi bật',
            style:
                AppTypography.featureHeading.copyWith(color: AppColors.white),
          ),
        ),
        ...trendingSongs.map((song) {
          return ListTile(
            key: Key('searchScreen_trendingSong_${song.id}'),
            onTap: () {
              final queue = trendingSongs
                  .map((s) => Song(
                        id: s.id,
                        title: s.title,
                        artistNames:
                            s.artists.map((a) => a.name as String).toList(),
                        coverUrl: s.coverUrl,
                        audioUrl: s.audioUrl,
                        durationSeconds: s.durationSeconds,
                      ))
                  .toList();
              final idx = trendingSongs.indexOf(song);
              context.read<PlayerBloc>().add(PlaySongRequested(
                    songs: queue,
                    index: idx < 0 ? 0 : idx,
                  ));
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xxs,
            ),
            leading: _SongCover(coverUrl: song.coverUrl),
            title: Text(
              song.title,
              style: AppTypography.bodyBold.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artists.map((a) => a.name).join(', '),
              style: AppTypography.caption.copyWith(color: AppColors.silver),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
    );
  }
}

class _SongCover extends StatelessWidget {
  final String? coverUrl;

  const _SongCover({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.resolveUrl(coverUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.subtle),
      child: SizedBox(
        width: 48,
        height: 48,
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _Placeholder(),
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.midCard,
      child: const Icon(Icons.music_note, color: AppColors.silver, size: 24),
    );
  }
}

// ---------------------------------------------------------------------------
// Genres (Browse by Genre)
// ---------------------------------------------------------------------------

class _GenresSection extends StatelessWidget {
  final List<Genre> genres;
  final ValueChanged<String> onSearchTapped;

  const _GenresSection({required this.genres, required this.onSearchTapped});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.lg,
            AppSpacing.base,
            AppSpacing.md,
          ),
          child: Text(
            'Khám phá theo thể loại',
            style:
                AppTypography.featureHeading.copyWith(color: AppColors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: genres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 3.0,
            ),
            itemBuilder: (context, index) {
              final genre = genres[index];
              return _GenreCard(
                key: Key('searchScreen_genreCard_${genre.id}'),
                genre: genre,
                onTap: () => onSearchTapped(genre.name),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Genre genre;
  final VoidCallback onTap;

  const _GenreCard({super.key, required this.genre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.standard),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (genre.coverUrl != null)
              Image.network(
                genre.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.midCard),
              )
            else
              Container(color: AppColors.midCard),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.nearBlack.withAlpha(180),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  genre.name,
                  style: AppTypography.bodyBold.copyWith(color: AppColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
