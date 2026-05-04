import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_song_item_model.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';

class PlaylistDetailModel extends PlaylistDetail {
  const PlaylistDetailModel({
    required super.id,
    required super.name,
    super.coverUrl,
    required super.totalSongs,
    required super.songs,
  });

  factory PlaylistDetailModel.fromJson(Map<String, dynamic> json) {
    final rawSongs = json['songs'] as List<dynamic>? ?? [];
    final songs = rawSongs
        .map((s) => PlaylistSongItemModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return PlaylistDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      totalSongs: json['totalSongs'] as int,
      songs: songs,
    );
  }
}
