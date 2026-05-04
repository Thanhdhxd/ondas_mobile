import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/home/data/models/song_summary_model.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';

class GenreModel extends Genre {
  const GenreModel({
    required super.id,
    required super.name,
    super.slug,
    super.description,
    super.coverUrl,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
    );
  }
}

class SearchSuggestionModel extends SearchSuggestion {
  const SearchSuggestionModel({
    required super.recentSearches,
    required super.trendingSearches,
    required super.trendingSongs,
    required super.genres,
  });

  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      recentSearches: (json['recentSearches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      trendingSearches: (json['trendingSearches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      trendingSongs: (json['trendingSongs'] as List<dynamic>?)
              ?.map((e) =>
                  SongSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
