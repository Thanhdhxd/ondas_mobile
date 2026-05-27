import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';
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
import 'package:ondas_mobile/features/songs/presentation/screens/song_list_screen.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';

class SearchSuggestionView extends StatelessWidget {
  final SearchSuggestion suggestion;
  final ValueChanged<String> onSearchTapped;
  final Set<int> selectedTagIds;
  final ValueChanged<Tag> onTagToggled;
  final String langCode;

  const SearchSuggestionView({
    super.key,
    required this.suggestion,
    required this.onSearchTapped,
    required this.selectedTagIds,
    required this.onTagToggled,
    required this.langCode,
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
            langCode: langCode,
          ),
        if (suggestion.trendingSearches.isNotEmpty)
          _TrendingSearchesSection(
            searches: suggestion.trendingSearches,
            onTap: onSearchTapped,
            langCode: langCode,
          ),
        if (suggestion.tags.isNotEmpty)
          TagBrowseSection(
            tags: suggestion.tags,
            selectedTagIds: selectedTagIds,
            onTagTapped: onTagToggled,
            langCode: langCode,
          ),
        if (suggestion.trendingSongs.isNotEmpty)
          _TrendingSongsSection(
            trendingSongs: suggestion.trendingSongs,
            langCode: langCode,
          ),
        if (suggestion.genres.isNotEmpty)
          _GenresSection(
            genres: suggestion.genres,
            onSearchTapped: onSearchTapped,
            langCode: langCode,
          ),
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
  final String langCode;

  const _RecentSearchesSection({
    required this.searches,
    required this.onTap,
    required this.langCode,
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
                  t(Str.searchRecent, langCode),
                  style: AppTypography.featureHeading.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              TextButton(
                key: const Key('searchScreen_clearHistoryButton'),
                onPressed: () => context.read<SearchBloc>().add(
                  const SearchHistoryCleared(),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  t(Str.searchClearAll, langCode),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.spotifyGreen,
                  ),
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
            leading: const Icon(
              Icons.history,
              color: AppColors.silver,
              size: 20,
            ),
            title: Text(
              query,
              style: AppTypography.body.copyWith(color: AppColors.white),
            ),
            trailing: const Icon(
              Icons.north_west,
              color: AppColors.silver,
              size: 16,
            ),
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
  final String langCode;

  const _TrendingSearchesSection({
    required this.searches,
    required this.onTap,
    required this.langCode,
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
              const Icon(
                Icons.trending_up,
                color: AppColors.spotifyGreen,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                t(Str.searchTrending, langCode),
                style: AppTypography.featureHeading.copyWith(
                  color: AppColors.white,
                ),
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
// Tags (Browse by Tags)
// ---------------------------------------------------------------------------

class TagBrowseSection extends StatelessWidget {
  final List<Tag> tags;
  final Set<int> selectedTagIds;
  final ValueChanged<Tag> onTagTapped;
  final String langCode;

  const TagBrowseSection({
    super.key,
    required this.tags,
    required this.selectedTagIds,
    required this.onTagTapped,
    required this.langCode,
  });

  static const List<String> _typeOrder = ['mood', 'activity', 'theme', 'era'];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Tag>>{};
    for (final tag in tags) {
      grouped.putIfAbsent(tag.type, () => []).add(tag);
    }

    final orderedEntries = _typeOrder
        .where(grouped.containsKey)
        .map((type) => MapEntry(type, grouped[type]!))
        .toList();

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
            t(Str.searchBrowseTags, langCode),
            style: AppTypography.featureHeading.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        ...orderedEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: _TagGroup(
              title: entry.key.toUpperCase(),
              tags: entry.value,
              selectedTagIds: selectedTagIds,
              onTagTapped: onTagTapped,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class _TagGroup extends StatelessWidget {
  final String title;
  final List<Tag> tags;
  final Set<int> selectedTagIds;
  final ValueChanged<Tag> onTagTapped;

  const _TagGroup({
    required this.title,
    required this.tags,
    required this.selectedTagIds,
    required this.onTagTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.caption.copyWith(color: AppColors.silver),
          ),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tags
              .map(
                (tag) => _TagChip(
                  key: Key('searchScreen_tagChip_${tag.id}'),
                  tag: tag,
                  isSelected: selectedTagIds.contains(tag.id),
                  onTap: () => onTagTapped(tag),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resolveTagColor(tag);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(22),
          borderRadius: BorderRadius.circular(AppRadius.fullPill),
          border: Border.all(
            color: color.withAlpha(isSelected ? 255 : 180),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: AppColors.nearBlack),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              tag.name,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.nearBlack : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveTagColor(Tag tag) {
    final fromHex = _tryParseHex(tag.colorHex);
    if (fromHex != null) return fromHex;

    return switch (tag.type) {
      'mood' => const Color(0xFF7F5CFF),
      'activity' => const Color(0xFFF6A43B),
      'theme' => const Color(0xFF3CB371),
      'era' => const Color(0xFFEA6A5E),
      _ => AppColors.lightBorder,
    };
  }

  Color? _tryParseHex(String? hex) {
    if (hex == null || !hex.startsWith('#') || hex.length != 7) return null;
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
}

// ---------------------------------------------------------------------------
// Trending Songs
// ---------------------------------------------------------------------------

class _TrendingSongsSection extends StatelessWidget {
  final List trendingSongs;
  final String langCode;

  const _TrendingSongsSection({
    required this.trendingSongs,
    required this.langCode,
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
          child: Text(
            t(Str.searchTrendingSongs, langCode),
            style: AppTypography.featureHeading.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        ...trendingSongs.map((song) {
          return ListTile(
            key: Key('searchScreen_trendingSong_${song.id}'),
            onTap: () {
              final queue = trendingSongs
                  .map(
                    (s) => Song(
                      id: s.id,
                      title: s.title,
                      artistNames: s.artists
                          .map((a) => a.name as String)
                          .toList(),
                      coverUrl: s.coverUrl,
                      audioUrl: s.audioUrl,
                      durationSeconds: s.durationSeconds,
                    ),
                  )
                  .toList();
              final idx = trendingSongs.indexOf(song);
              context.read<PlayerBloc>().add(
                PlaySongRequested(songs: queue, index: idx < 0 ? 0 : idx),
              );
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
                errorBuilder: (context, error, stackTrace) =>
                    const _Placeholder(),
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
  final String langCode;

  const _GenresSection({
    required this.genres,
    required this.onSearchTapped,
    required this.langCode,
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
            AppSpacing.md,
          ),
          child: Text(
            t(Str.searchExploreGenres, langCode),
            style: AppTypography.featureHeading.copyWith(
              color: AppColors.white,
            ),
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
                onTap: () => context.push(
                  '/songs/genre/${genre.id}',
                  extra: SongListRouteData(
                    genreId: genre.id,
                    title: genre.name,
                    coverUrl: genre.coverUrl,
                  ),
                ),
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
                errorBuilder: (context, error, stackTrace) =>
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
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.white,
                  ),
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
