import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';

class Genre extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? coverUrl;

  const Genre({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.coverUrl,
  });

  @override
  List<Object?> get props => [id, name, slug, description, coverUrl];
}

class SearchSuggestion extends Equatable {
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final List<SongSummary> trendingSongs;
  final List<Genre> genres;
  final List<Tag> tags;

  const SearchSuggestion({
    required this.recentSearches,
    required this.trendingSearches,
    required this.trendingSongs,
    required this.genres,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        recentSearches,
        trendingSearches,
        trendingSongs,
        genres,
      tags,
      ];
}
