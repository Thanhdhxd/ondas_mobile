import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:ondas_mobile/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:ondas_mobile/features/favorites/presentation/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  static const _pageSize = 20;

  FavoritesBloc({
    required GetFavoritesUseCase getFavoritesUseCase,
    required RemoveFavoriteUseCase removeFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _removeFavoriteUseCase = removeFavoriteUseCase,
        super(const FavoritesInitial()) {
    on<FavoritesListRequested>(_onListRequested);
    on<FavoritesLoadMoreRequested>(_onLoadMoreRequested);
    on<FavoriteRemovedFromList>(_onRemovedFromList);
  }

  Future<void> _onListRequested(
    FavoritesListRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesListLoading());
    try {
      final result = await _getFavoritesUseCase(page: 0, size: _pageSize);
      emit(FavoritesListLoaded(
        items: result.items,
        hasMore: result.page < result.totalPages - 1,
        currentPage: result.page,
      ));
    } catch (e) {
      emit(FavoritesListError(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    FavoritesLoadMoreRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = state;
    if (current is! FavoritesListLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await _getFavoritesUseCase(page: nextPage, size: _pageSize);
      emit(current.copyWith(
        items: [...current.items, ...result.items],
        hasMore: result.page < result.totalPages - 1,
        currentPage: result.page,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRemovedFromList(
    FavoriteRemovedFromList event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = state;
    if (current is! FavoritesListLoaded) return;

    final optimisticItems =
        current.items.where((item) => item.song.id != event.songId).toList();
    emit(current.copyWith(items: optimisticItems));

    try {
      await _removeFavoriteUseCase(event.songId);
    } catch (_) {
      emit(current);
    }
  }
}
