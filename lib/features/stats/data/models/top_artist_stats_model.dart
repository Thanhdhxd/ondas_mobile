import 'package:ondas_mobile/features/stats/domain/entities/top_artist_stats.dart';

class TopArtistStatsModel extends TopArtistStats {
  const TopArtistStatsModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    required super.playCount,
  });

  factory TopArtistStatsModel.fromJson(Map<String, dynamic> json) {
    return TopArtistStatsModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
    );
  }
}
