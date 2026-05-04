import 'package:equatable/equatable.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesListRequested extends FavoritesEvent {
  const FavoritesListRequested();
}

class FavoritesLoadMoreRequested extends FavoritesEvent {
  const FavoritesLoadMoreRequested();
}

class FavoriteRemovedFromList extends FavoritesEvent {
  final String songId;

  const FavoriteRemovedFromList(this.songId);

  @override
  List<Object?> get props => [songId];
}
