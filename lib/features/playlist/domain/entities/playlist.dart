import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';

class PlaylistSongItem extends Equatable {
  final int position;
  final String addedAt;
  final SongSummary song;

  const PlaylistSongItem({
    required this.position,
    required this.addedAt,
    required this.song,
  });

  @override
  List<Object?> get props => [position, addedAt, song];
}

class Playlist extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int totalSongs;
  final String createdAt;
  final String updatedAt;
  final List<PlaylistSongItem> songs;

  const Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverUrl,
    required this.isPublic,
    required this.totalSongs,
    required this.createdAt,
    required this.updatedAt,
    required this.songs,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        coverUrl,
        isPublic,
        totalSongs,
        createdAt,
        updatedAt,
        songs,
      ];
}
