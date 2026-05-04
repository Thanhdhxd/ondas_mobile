import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';

part 'save_to_playlist_event.dart';
part 'save_to_playlist_state.dart';

class SaveToPlaylistBloc
    extends Bloc<SaveToPlaylistEvent, SaveToPlaylistState> {
  final GetMyPlaylistsUseCase _getMyPlaylists;
  final AddSongToPlaylistUseCase _addSong;
  final RemoveSongFromPlaylistUseCase _removeSong;
  final CreatePlaylistUseCase _createPlaylist;

  SaveToPlaylistBloc({
    required GetMyPlaylistsUseCase getMyPlaylistsUseCase,
    required AddSongToPlaylistUseCase addSongToPlaylistUseCase,
    required RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
  })  : _getMyPlaylists = getMyPlaylistsUseCase,
        _addSong = addSongToPlaylistUseCase,
        _removeSong = removeSongFromPlaylistUseCase,
        _createPlaylist = createPlaylistUseCase,
        super(const SaveToPlaylistInitial()) {
    on<SaveToPlaylistStarted>(_onStarted);
    on<PlaylistToggled>(_onToggled);
    on<CreatePlaylistRequested>(_onCreatePlaylist);
  }

  Future<void> _onStarted(
    SaveToPlaylistStarted event,
    Emitter<SaveToPlaylistState> emit,
  ) async {
    emit(const SaveToPlaylistLoading());
    try {
      final playlists = await _getMyPlaylists(songId: event.songId);
      emit(SaveToPlaylistReady(playlists: playlists));
    } catch (e) {
      emit(SaveToPlaylistError(e.toString()));
    }
  }

  Future<void> _onToggled(
    PlaylistToggled event,
    Emitter<SaveToPlaylistState> emit,
  ) async {
    final current = state;
    if (current is! SaveToPlaylistReady) return;

    // Optimistic update
    final updated = current.playlists.map((p) {
      if (p.id == event.playlistId) {
        return p.copyWith(
          containsSong: !event.currentlyContains,
          totalSongs: event.currentlyContains
              ? (p.totalSongs - 1).clamp(0, p.totalSongs)
              : p.totalSongs + 1,
        );
      }
      return p;
    }).toList();
    emit(current.copyWith(playlists: updated));

    try {
      if (event.currentlyContains) {
        await _removeSong(
          playlistId: event.playlistId,
          songId: event.songId,
        );
      } else {
        await _addSong(
          playlistId: event.playlistId,
          songId: event.songId,
        );
      }
    } catch (_) {
      // Revert optimistic update on failure
      emit(current);
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistRequested event,
    Emitter<SaveToPlaylistState> emit,
  ) async {
    final current = state;
    if (current is! SaveToPlaylistReady) return;

    emit(current.copyWith(isCreating: true));
    try {
      final newPlaylist = await _createPlaylist(
        CreatePlaylistParams(
          name: event.name,
          coverImageUrl: event.coverUrl,
        ),
      );

      // Add current song to the newly created playlist
      await _addSong(
        playlistId: newPlaylist.id,
        songId: event.songId,
      );

      // Refresh the full list to reflect accurate state
      final refreshed = await _getMyPlaylists(songId: event.songId);
      emit(SaveToPlaylistReady(playlists: refreshed));
    } catch (e) {
      emit(current.copyWith(isCreating: false));
    }
  }
}
