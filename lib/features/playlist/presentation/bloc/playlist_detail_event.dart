import 'package:equatable/equatable.dart';

abstract class PlaylistDetailEvent extends Equatable {
  const PlaylistDetailEvent();

  @override
  List<Object?> get props => [];
}

class PlaylistDetailLoadRequested extends PlaylistDetailEvent {
  final String id;

  const PlaylistDetailLoadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class PlaylistDetailRefreshRequested extends PlaylistDetailEvent {
  const PlaylistDetailRefreshRequested();
}

class PlaylistDetailSongRemoveRequested extends PlaylistDetailEvent {
  final String songId;

  const PlaylistDetailSongRemoveRequested(this.songId);

  @override
  List<Object?> get props => [songId];
}
