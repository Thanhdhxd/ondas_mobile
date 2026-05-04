import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLibraryPlaylistsUseCase _getPlaylists;
  final CreatePlaylistUseCase _createPlaylist;
  final DeletePlaylistUseCase _deletePlaylist;

  LibraryBloc({
    required GetLibraryPlaylistsUseCase getLibraryPlaylistsUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
    required DeletePlaylistUseCase deletePlaylistUseCase,
  })  : _getPlaylists = getLibraryPlaylistsUseCase,
        _createPlaylist = createPlaylistUseCase,
        _deletePlaylist = deletePlaylistUseCase,
        super(const LibraryInitial()) {
    on<LibraryStarted>(_onLoad);
    on<LibraryRefreshRequested>(_onLoad);
    on<LibraryPlaylistCreateRequested>(_onCreate);
    on<LibraryPlaylistDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    LibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());
    try {
      final playlists = await _getPlaylists();
      emit(LibraryLoaded(playlists: playlists));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onCreate(
    LibraryPlaylistCreateRequested event,
    Emitter<LibraryState> emit,
  ) async {
    final current = state;
    if (current is! LibraryLoaded) return;

    emit(current.copyWith(isCreating: true));
    try {
      final newPlaylist = await _createPlaylist(
        CreatePlaylistParams(name: event.name),
      );
      final updated = [newPlaylist, ...current.playlists];
      emit(LibraryLoaded(playlists: updated));
    } catch (e) {
      emit(current.copyWith(isCreating: false));
    }
  }

  Future<void> _onDelete(
    LibraryPlaylistDeleteRequested event,
    Emitter<LibraryState> emit,
  ) async {
    final current = state;
    if (current is! LibraryLoaded) return;

    // Optimistic removal
    final remaining =
        current.playlists.where((p) => p.id != event.playlistId).toList();
    emit(current.copyWith(playlists: remaining));

    try {
      await _deletePlaylist(event.playlistId);
    } catch (_) {
      emit(current); // revert on failure
    }
  }
}
