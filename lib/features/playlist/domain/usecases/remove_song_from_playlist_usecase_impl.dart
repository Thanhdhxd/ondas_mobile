import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';

class RemoveSongFromPlaylistUseCaseImpl implements RemoveSongFromPlaylistUseCase {
  final PlaylistRepository _repository;

  const RemoveSongFromPlaylistUseCaseImpl(this._repository);

  @override
  Future<void> call({required String playlistId, required String songId}) {
    return _repository.removeSongFromPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
  }
}
