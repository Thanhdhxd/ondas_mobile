import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_song_item.dart';

class PlaylistDetail extends Equatable {
  final String id;
  final String name;
  final String? coverUrl;
  final int totalSongs;
  final List<PlaylistSongItem> songs;

  const PlaylistDetail({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.totalSongs,
    required this.songs,
  });

  PlaylistDetail copyWith({
    String? name,
    String? coverUrl,
    int? totalSongs,
    List<PlaylistSongItem>? songs,
  }) {
    return PlaylistDetail(
      id: id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      totalSongs: totalSongs ?? this.totalSongs,
      songs: songs ?? this.songs,
    );
  }

  @override
  List<Object?> get props => [id, name, coverUrl, totalSongs, songs];
}
