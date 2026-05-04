part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailEvent extends Equatable {
  const PlaylistDetailEvent();
}

final class PlaylistDetailStarted extends PlaylistDetailEvent {
  final String playlistId;
  const PlaylistDetailStarted(this.playlistId);
  @override
  List<Object?> get props => [playlistId];
}

final class PlaylistDetailSongRemoved extends PlaylistDetailEvent {
  final String songId;
  const PlaylistDetailSongRemoved(this.songId);
  @override
  List<Object?> get props => [songId];
}

final class PlaylistDetailReordered extends PlaylistDetailEvent {
  final List<String> songIds;
  const PlaylistDetailReordered(this.songIds);
  @override
  List<Object?> get props => [songIds];
}

final class PlaylistDetailNameUpdated extends PlaylistDetailEvent {
  final String name;
  const PlaylistDetailNameUpdated(this.name);
  @override
  List<Object?> get props => [name];
}
