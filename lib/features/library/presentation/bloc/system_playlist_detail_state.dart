part of 'system_playlist_detail_bloc.dart';

sealed class SystemPlaylistDetailState extends Equatable {
  const SystemPlaylistDetailState();

  @override
  List<Object?> get props => [];
}

final class SystemPlaylistDetailInitial extends SystemPlaylistDetailState {
  const SystemPlaylistDetailInitial();
}

final class SystemPlaylistDetailLoading extends SystemPlaylistDetailState {
  const SystemPlaylistDetailLoading();
}

final class SystemPlaylistDetailLoaded extends SystemPlaylistDetailState {
  final PlaylistDetail detail;

  const SystemPlaylistDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

final class SystemPlaylistDetailError extends SystemPlaylistDetailState {
  final String message;

  const SystemPlaylistDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
