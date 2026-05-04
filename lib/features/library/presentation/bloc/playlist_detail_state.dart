part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();
}

final class PlaylistDetailInitial extends PlaylistDetailState {
  const PlaylistDetailInitial();
  @override
  List<Object?> get props => [];
}

final class PlaylistDetailLoading extends PlaylistDetailState {
  const PlaylistDetailLoading();
  @override
  List<Object?> get props => [];
}

final class PlaylistDetailLoaded extends PlaylistDetailState {
  final PlaylistDetail detail;
  const PlaylistDetailLoaded(this.detail);

  PlaylistDetailLoaded copyWith({PlaylistDetail? detail}) =>
      PlaylistDetailLoaded(detail ?? this.detail);

  @override
  List<Object?> get props => [detail];
}

final class PlaylistDetailError extends PlaylistDetailState {
  final String message;
  const PlaylistDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
