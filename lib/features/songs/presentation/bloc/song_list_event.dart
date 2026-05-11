import 'package:equatable/equatable.dart';

abstract class SongListEvent extends Equatable {
  const SongListEvent();

  @override
  List<Object?> get props => [];
}

class SongListStarted extends SongListEvent {
  final String? artistId;
  final String? albumId;
  final int? genreId;

  const SongListStarted({this.artistId, this.albumId, this.genreId});

  @override
  List<Object?> get props => [artistId, albumId, genreId];
}

class SongListLoadMoreRequested extends SongListEvent {
  const SongListLoadMoreRequested();
}
