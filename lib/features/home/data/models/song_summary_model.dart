import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class ArtistRefModel extends ArtistRef {
  const ArtistRefModel({
    required super.id,
    required super.name,
    super.avatarUrl,
  });

  factory ArtistRefModel.fromJson(Map<String, dynamic> json) {
    return ArtistRefModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: ApiConstants.resolveUrl(json['avatarUrl'] as String?),
    );
  }
}

class GenreRefModel extends GenreRef {
  const GenreRefModel({required super.id, required super.name});

  factory GenreRefModel.fromJson(Map<String, dynamic> json) {
    return GenreRefModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class SongSummaryModel extends SongSummary {
  const SongSummaryModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.durationSeconds,
    required super.audioUrl,
    super.coverUrl,
    required super.playCount,
    required super.active,
    required super.artists,
    required super.genres,
  });

  factory SongSummaryModel.fromJson(Map<String, dynamic> json) {
    return SongSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      durationSeconds: json['durationSeconds'] as int,
      audioUrl: ApiConstants.resolveUrl(json['audioUrl'] as String?)!,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      playCount: json['playCount'] as int,
      active: json['active'] as bool,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistRefModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      genres: (json['genres'] as List<dynamic>)
          .map((e) => GenreRefModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
