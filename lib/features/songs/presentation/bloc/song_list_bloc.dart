import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/songs/domain/usecases/get_songs_usecase.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_event.dart';
import 'package:ondas_mobile/features/songs/presentation/bloc/song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  final GetSongsUseCase _getSongsUseCase;

  static const int _pageSize = 20;

  String? _artistId;
  String? _albumId;

  SongListBloc({required GetSongsUseCase getSongsUseCase})
      : _getSongsUseCase = getSongsUseCase,
        super(const SongListInitial()) {
    on<SongListStarted>(_onStarted);
    on<SongListLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onStarted(
    SongListStarted event,
    Emitter<SongListState> emit,
  ) async {
    _artistId = event.artistId;
    _albumId = event.albumId;

    emit(const SongListLoading());
    final result = await _getSongsUseCase(GetSongsParams(
      artistId: _artistId,
      albumId: _albumId,
      page: 0,
      size: _pageSize,
    ));
    await result.fold(
      (failure) async => emit(SongListFailure(message: failure.message)),
      (page) async => emit(SongListLoaded(
        songs: page.items,
        page: 0,
        totalPages: page.totalPages,
        hasMore: page.page + 1 < page.totalPages,
      )),
    );
  }

  Future<void> _onLoadMore(
    SongListLoadMoreRequested event,
    Emitter<SongListState> emit,
  ) async {
    final current = state;
    if (current is! SongListLoaded || current is SongListLoadingMore || !current.hasMore) return;

    final nextPage = current.page + 1;
    emit(SongListLoadingMore(
      songs: current.songs,
      page: current.page,
      totalPages: current.totalPages,
      hasMore: current.hasMore,
    ));

    final result = await _getSongsUseCase(GetSongsParams(
      artistId: _artistId,
      albumId: _albumId,
      page: nextPage,
      size: _pageSize,
    ));
    await result.fold(
      (failure) async => emit(SongListFailure(message: failure.message)),
      (page) async => emit(SongListLoaded(
        songs: [...current.songs, ...page.items],
        page: nextPage,
        totalPages: page.totalPages,
        hasMore: nextPage + 1 < page.totalPages,
      )),
    );
  }
}
