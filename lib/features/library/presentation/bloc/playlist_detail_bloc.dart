import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final GetPlaylistDetailUseCase _getDetail;
  final RemoveSongFromPlaylistUseCase _removeSong;
  final ReorderPlaylistSongsUseCase _reorder;
  final UpdatePlaylistUseCase _updatePlaylist;

  PlaylistDetailBloc({
    required GetPlaylistDetailUseCase getPlaylistDetailUseCase,
    required RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase,
    required ReorderPlaylistSongsUseCase reorderPlaylistSongsUseCase,
    required UpdatePlaylistUseCase updatePlaylistUseCase,
  })  : _getDetail = getPlaylistDetailUseCase,
        _removeSong = removeSongFromPlaylistUseCase,
        _reorder = reorderPlaylistSongsUseCase,
        _updatePlaylist = updatePlaylistUseCase,
        super(const PlaylistDetailInitial()) {
    on<PlaylistDetailStarted>(_onStarted);
    on<PlaylistDetailSongRemoved>(_onSongRemoved);
    on<PlaylistDetailReordered>(_onReordered);
    on<PlaylistDetailNameUpdated>(_onNameUpdated);
  }

  Future<void> _onStarted(
    PlaylistDetailStarted event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    emit(const PlaylistDetailLoading());
    try {
      final detail = await _getDetail(event.playlistId);
      emit(PlaylistDetailLoaded(detail));
    } catch (e) {
      emit(PlaylistDetailError(e.toString()));
    }
  }

  Future<void> _onSongRemoved(
    PlaylistDetailSongRemoved event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final songs = current.detail.songs
        .where((s) => s.songId != event.songId)
        .toList();
    final reindexed = songs
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key + 1))
        .toList();

    emit(current.copyWith(
      detail: current.detail.copyWith(
        songs: reindexed,
        totalSongs: reindexed.length,
      ),
    ));

    try {
      await _removeSong(
        playlistId: current.detail.id,
        songId: event.songId,
      );
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onReordered(
    PlaylistDetailReordered event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final songMap = {for (final s in current.detail.songs) s.songId: s};
    final reordered = event.songIds
        .asMap()
        .entries
        .map((e) => songMap[e.value]!.copyWith(position: e.key + 1))
        .toList();

    emit(current.copyWith(
      detail: current.detail.copyWith(songs: reordered),
    ));

    try {
      await _reorder(ReorderPlaylistSongsParams(
        playlistId: current.detail.id,
        songIds: event.songIds,
      ));
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onNameUpdated(
    PlaylistDetailNameUpdated event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    try {
      await _updatePlaylist(
        UpdatePlaylistParams(id: current.detail.id, name: event.name),
      );
      emit(current.copyWith(
        detail: current.detail.copyWith(name: event.name),
      ));
    } catch (_) {
      // Stay in current state; name update failed silently
    }
  }
}
