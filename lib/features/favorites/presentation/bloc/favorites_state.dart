import 'package:equatable/equatable.dart';
import 'package:ondas_mobile/features/favorites/domain/entities/favorite_song.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesListLoading extends FavoritesState {
  const FavoritesListLoading();
}

class FavoritesListLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const FavoritesListLoaded({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  FavoritesListLoaded copyWith({
    List<FavoriteItem>? items,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return FavoritesListLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasMore, currentPage, isLoadingMore];
}

class FavoritesListError extends FavoritesState {
  final String message;

  const FavoritesListError(this.message);

  @override
  List<Object?> get props => [message];
}
