import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

/// A minimal song model returned inside PlaylistResponse.songs.
/// Fields not present in the playlist API response are given safe defaults.
class PlaylistSongSummaryModel extends SongSummary {
  const PlaylistSongSummaryModel({
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

  factory PlaylistSongSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlaylistSongSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int,
      audioUrl: ApiConstants.resolveUrl(json['audioUrl'] as String?)!,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      playCount: json['playCount'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      artists: const [],
      genres: const [],
    );
  }
}
