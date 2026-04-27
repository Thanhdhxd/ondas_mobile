import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final GetPlaylistDetailUseCase _getDetail;
  final RemoveSongFromPlaylistUseCase _removeSong;

  String? _playlistId;

  PlaylistDetailBloc({
    required GetPlaylistDetailUseCase getPlaylistDetailUseCase,
    required RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase,
  })  : _getDetail = getPlaylistDetailUseCase,
        _removeSong = removeSongFromPlaylistUseCase,
        super(const PlaylistDetailInitial()) {
    on<PlaylistDetailLoadRequested>(_onLoadRequested);
    on<PlaylistDetailRefreshRequested>(_onRefreshRequested);
    on<PlaylistDetailSongRemoveRequested>(_onSongRemoveRequested);
  }

  Future<void> _onLoadRequested(
    PlaylistDetailLoadRequested event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    _playlistId = event.id;
    emit(const PlaylistDetailLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshRequested(
    PlaylistDetailRefreshRequested event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    if (_playlistId == null) return;
    await _fetchAndEmit(emit);
  }

  Future<void> _onSongRemoveRequested(
    PlaylistDetailSongRemoveRequested event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    if (_playlistId == null) return;
    final result = await _removeSong(
      RemoveSongFromPlaylistParams(
        playlistId: _playlistId!,
        songId: event.songId,
      ),
    );
    result.fold(
      (failure) => emit(PlaylistDetailFailure(message: failure.message)),
      (updated) => emit(PlaylistDetailLoaded(playlist: updated)),
    );
  }

  Future<void> _fetchAndEmit(Emitter<PlaylistDetailState> emit) async {
    final result = await _getDetail(_playlistId!);
    result.fold(
      (failure) => emit(PlaylistDetailFailure(message: failure.message)),
      (playlist) => emit(PlaylistDetailLoaded(playlist: playlist)),
    );
  }
}
