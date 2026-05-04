import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';
import 'package:ondas_mobile/features/search/domain/usecases/clear_search_history_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/get_search_suggestions_usecase.dart';
import 'package:ondas_mobile/features/search/domain/usecases/search_usecase.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ondas_mobile/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  final GetSearchSuggestionsUseCase _getSuggestionsUseCase;
  final ClearSearchHistoryUseCase _clearHistoryUseCase;

  static const int _pageSize = 10;

  /// Cached suggestions so we can restore them instantly when the user
  /// clears their query without a network round-trip.
  SearchSuggestion? _cachedSuggestion;

  SearchBloc({
    required SearchUseCase searchUseCase,
    required GetSearchSuggestionsUseCase getSuggestionsUseCase,
    required ClearSearchHistoryUseCase clearHistoryUseCase,
  })  : _searchUseCase = searchUseCase,
        _getSuggestionsUseCase = getSuggestionsUseCase,
        _clearHistoryUseCase = clearHistoryUseCase,
        super(const SearchSuggestionsLoading()) {
    on<SuggestionsRequested>(_onSuggestionsRequested);
    on<SearchHistoryCleared>(_onHistoryCleared);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchLoadMoreRequested>(_onLoadMore);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onSuggestionsRequested(
    SuggestionsRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchSuggestionsLoading());
    final result = await _getSuggestionsUseCase();
    await result.fold(
      (failure) async => emit(SearchFailure(message: failure.message)),
      (suggestion) async {
        _cachedSuggestion = suggestion;
        emit(SearchSuggestionsLoaded(suggestion: suggestion));
      },
    );
  }

  Future<void> _onHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _clearHistoryUseCase();
    // Re-fetch so the recentSearches list is updated
    add(const SuggestionsRequested());
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      _restoreSuggestions(emit);
      return;
    }
    emit(const SearchLoading());
    final result = await _searchUseCase(
      SearchParams(query: query, page: 0, size: _pageSize),
    );
    await result.fold(
      (failure) async => emit(SearchFailure(message: failure.message)),
      (data) async {
        final hasMore = data.songs.length >= _pageSize ||
            data.artists.length >= _pageSize ||
            data.albums.length >= _pageSize;
        emit(SearchLoaded(
          query: data.query,
          songs: data.songs,
          artists: data.artists,
          albums: data.albums,
          totalSongs: data.totalSongs,
          totalArtists: data.totalArtists,
          totalAlbums: data.totalAlbums,
          page: 0,
          hasMore: hasMore,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchLoaded || current is SearchLoadingMore || !current.hasMore) return;

    final nextPage = current.page + 1;
    emit(SearchLoadingMore(
      query: current.query,
      songs: current.songs,
      artists: current.artists,
      albums: current.albums,
      totalSongs: current.totalSongs,
      totalArtists: current.totalArtists,
      totalAlbums: current.totalAlbums,
      page: current.page,
      hasMore: current.hasMore,
    ));

    final result = await _searchUseCase(
      SearchParams(query: current.query, page: nextPage, size: _pageSize),
    );
    await result.fold(
      (failure) async => emit(SearchFailure(message: failure.message)),
      (data) async {
        final hasMore = data.songs.length >= _pageSize ||
            data.artists.length >= _pageSize ||
            data.albums.length >= _pageSize;
        emit(SearchLoaded(
          query: data.query,
          songs: [...current.songs, ...data.songs],
          artists: [...current.artists, ...data.artists],
          albums: [...current.albums, ...data.albums],
          totalSongs: data.totalSongs,
          totalArtists: data.totalArtists,
          totalAlbums: data.totalAlbums,
          page: nextPage,
          hasMore: hasMore,
        ));
      },
    );
  }

  Future<void> _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    _restoreSuggestions(emit);
  }

  void _restoreSuggestions(Emitter<SearchState> emit) {
    if (_cachedSuggestion != null) {
      emit(SearchSuggestionsLoaded(suggestion: _cachedSuggestion!));
    } else {
      add(const SuggestionsRequested());
    }
  }
}
