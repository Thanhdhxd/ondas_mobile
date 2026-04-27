import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_song_item_model.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    super.coverUrl,
    required super.isPublic,
    required super.totalSongs,
    required super.createdAt,
    required super.updatedAt,
    required super.songs,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      isPublic: (json['isPublic'] as bool?) ?? false,
      totalSongs: json['totalSongs'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      songs: (json['songs'] as List<dynamic>)
          .map((e) => PlaylistSongItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
