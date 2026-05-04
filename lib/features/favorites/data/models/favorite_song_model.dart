import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';

class FavoriteSongModel extends FavoriteSong {
  const FavoriteSongModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.audioUrl,
    required super.durationSeconds,
    required super.artistNames,
  });

  factory FavoriteSongModel.fromJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();

    return FavoriteSongModel(
      id: json['songId'] as String,
      title: json['title'] as String,
      coverUrl: ApiConstants.resolveUrl(json['coverUrl'] as String?),
      audioUrl: ApiConstants.resolveUrl(json['audioUrl'] as String?) ?? '',
      durationSeconds: json['durationSeconds'] as int,
      artistNames: artists,
    );
  }
}

class FavoriteItemModel extends FavoriteItem {
  const FavoriteItemModel({
    required super.id,
    required super.song,
    required super.addedAt,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: json['songId'] as String,
      song: FavoriteSongModel.fromJson(json),
      addedAt: DateTime.parse(json['favoritedAt'] as String),
    );
  }
}
