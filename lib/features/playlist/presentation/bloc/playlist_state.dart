import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistLoaded({required this.playlists});

  @override
  List<Object?> get props => [playlists];
}

class PlaylistFailure extends PlaylistState {
  final String message;

  const PlaylistFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class PlaylistOperationSuccess extends PlaylistState {
  final List<Playlist> playlists;

  const PlaylistOperationSuccess({required this.playlists});

  @override
  List<Object?> get props => [playlists];
}
