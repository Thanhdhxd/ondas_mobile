import 'package:equatable/equatable.dart';

abstract class SongListEvent extends Equatable {
  const SongListEvent();

  @override
  List<Object?> get props => [];
}

class SongListStarted extends SongListEvent {
  final String? artistId;
  final String? albumId;

  const SongListStarted({this.artistId, this.albumId});

  @override
  List<Object?> get props => [artistId, albumId];
}

class SongListLoadMoreRequested extends SongListEvent {
  const SongListLoadMoreRequested();
}
