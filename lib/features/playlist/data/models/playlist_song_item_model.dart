import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';

class PlaylistSongItemModel extends PlaylistSongItem {
  const PlaylistSongItemModel({
    required super.position,
    required super.songId,
    required super.title,
    super.coverUrl,
    required super.durationSeconds,
    super.audioUrl = '',
    super.artistNames = const <String>[],
  });

  factory PlaylistSongItemModel.fromJson(Map<String, dynamic> json) {
    final song = json['song'] as Map<String, dynamic>;
    final artists = song['artists'] as List<dynamic>?;
    return PlaylistSongItemModel(
      position: json['position'] as int,
      songId: song['id'] as String,
      title: song['title'] as String,
      coverUrl: ApiConstants.resolveUrl(song['coverUrl'] as String?),
      durationSeconds: song['durationSeconds'] as int? ?? 0,
      audioUrl: ApiConstants.resolveUrl(song['audioUrl'] as String?) ?? '',
      artistNames: artists != null
          ? artists
              .map((a) => (a as Map<String, dynamic>)['name'] as String)
              .toList()
          : const <String>[],
    );
  }
}
