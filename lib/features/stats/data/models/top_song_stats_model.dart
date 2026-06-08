import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_song_stats.dart';

class TopSongStatsModel extends TopSongStats {
  const TopSongStatsModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.playCount,
    required super.artists,
  });

  factory TopSongStatsModel.fromJson(Map<String, dynamic> json) {
    return TopSongStatsModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      artists: (json['artists'] as List<dynamic>?)?.map((e) {
            return ArtistRef(
              id: e['id'] as String? ?? '',
              name: e['name'] as String? ?? '',
              avatarUrl: e['avatarUrl'] as String?,
            );
          }).toList() ??
          [],
    );
  }
}
