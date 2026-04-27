import 'package:ondas_mobile/features/playlist/data/models/playlist_song_summary_model.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

class PlaylistSongItemModel extends PlaylistSongItem {
  const PlaylistSongItemModel({
    required super.position,
    required super.addedAt,
    required super.song,
  });

  factory PlaylistSongItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistSongItemModel(
      position: json['position'] as int,
      addedAt: json['addedAt'] as String,
      song: PlaylistSongSummaryModel.fromJson(json['song'] as Map<String, dynamic>),
    );
  }
}
