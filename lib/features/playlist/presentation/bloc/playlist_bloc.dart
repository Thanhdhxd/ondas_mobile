import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:ondas_mobile/features/playlist/presentation/bloc/playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetMyPlaylistsUseCase _getMyPlaylists;
  final CreatePlaylistUseCase _createPlaylist;
  final DeletePlaylistUseCase _deletePlaylist;

  PlaylistBloc({
    required GetMyPlaylistsUseCase getMyPlaylistsUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
    required DeletePlaylistUseCase deletePlaylistUseCase,
  })  : _getMyPlaylists = getMyPlaylistsUseCase,
        _createPlaylist = createPlaylistUseCase,
        _deletePlaylist = deletePlaylistUseCase,
        super(const PlaylistInitial()) {
    on<PlaylistLoadRequested>(_onLoadRequested);
    on<PlaylistRefreshRequested>(_onRefreshRequested);
    on<PlaylistCreateRequested>(_onCreateRequested);
    on<PlaylistDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    PlaylistLoadRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshRequested(
    PlaylistRefreshRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _onCreateRequested(
    PlaylistCreateRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _createPlaylist(
      CreatePlaylistParams(
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      ),
    );
    await result.fold(
      (failure) async => emit(PlaylistFailure(message: failure.message)),
      (_) async => _fetchAndEmit(emit, success: true),
    );
  }

  Future<void> _onDeleteRequested(
    PlaylistDeleteRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _deletePlaylist(event.id);
    await result.fold(
      (failure) async => emit(PlaylistFailure(message: failure.message)),
      (_) async => _fetchAndEmit(emit, success: true),
    );
  }

  Future<void> _fetchAndEmit(
    Emitter<PlaylistState> emit, {
    bool success = false,
  }) async {
    final result =
        await _getMyPlaylists(const GetMyPlaylistsParams());
    result.fold(
      (failure) => emit(PlaylistFailure(message: failure.message)),
      (page) {
        final playlists = page.items;
        if (success) {
          emit(PlaylistOperationSuccess(playlists: playlists));
        } else {
          emit(PlaylistLoaded(playlists: playlists));
        }
      },
    );
  }
}
