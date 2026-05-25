import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/network/dio_failure_mapper.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_system_playlists_usecase.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLibraryPlaylistsUseCase _getPlaylists;
  final GetSystemPlaylistsUseCase _getSystemPlaylists;
  final CreatePlaylistUseCase _createPlaylist;
  final DeletePlaylistUseCase _deletePlaylist;

  LibraryBloc({
    required GetLibraryPlaylistsUseCase getLibraryPlaylistsUseCase,
    required GetSystemPlaylistsUseCase getSystemPlaylistsUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
    required DeletePlaylistUseCase deletePlaylistUseCase,
  })  : _getPlaylists = getLibraryPlaylistsUseCase,
        _getSystemPlaylists = getSystemPlaylistsUseCase,
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
      final results = await Future.wait([
        _getPlaylists(),
        _getSystemPlaylists(),
      ]);
      emit(LibraryLoaded(
        playlists: results[0],
        systemPlaylists: results[1],
      ));
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
      emit(current.copyWith(playlists: updated, isCreating: false));
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
