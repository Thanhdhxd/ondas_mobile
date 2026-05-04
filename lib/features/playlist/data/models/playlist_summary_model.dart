import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

class PlaylistSummaryModel extends PlaylistSummary {
  const PlaylistSummaryModel({
    required super.id,
    required super.name,
    super.coverUrl,
    required super.totalSongs,
    required super.containsSong,
  });

  factory PlaylistSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlaylistSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      totalSongs: json['totalSongs'] as int,
      containsSong: json['containsSong'] as bool? ?? false,
    );
  }
}
