import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

abstract class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();

  @override
  List<Object?> get props => [];
}

class PlaylistDetailInitial extends PlaylistDetailState {
  const PlaylistDetailInitial();
}

class PlaylistDetailLoading extends PlaylistDetailState {
  const PlaylistDetailLoading();
}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final Playlist playlist;

  const PlaylistDetailLoaded({required this.playlist});

  @override
  List<Object?> get props => [playlist];
}

class PlaylistDetailFailure extends PlaylistDetailState {
  final String message;

  const PlaylistDetailFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
