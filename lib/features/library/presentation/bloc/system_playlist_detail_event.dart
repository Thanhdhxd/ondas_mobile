part of 'system_playlist_detail_bloc.dart';

sealed class SystemPlaylistDetailEvent extends Equatable {
  const SystemPlaylistDetailEvent();

  @override
  List<Object?> get props => [];
}

final class SystemPlaylistDetailStarted extends SystemPlaylistDetailEvent {
  final String playlistId;

  const SystemPlaylistDetailStarted(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}
