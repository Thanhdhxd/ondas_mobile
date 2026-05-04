import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';

class AddSongToPlaylistUseCaseImpl implements AddSongToPlaylistUseCase {
  final PlaylistRepository _repository;

  const AddSongToPlaylistUseCaseImpl(this._repository);

  @override
  Future<void> call({required String playlistId, required String songId}) {
    return _repository.addSongToPlaylist(playlistId: playlistId, songId: songId);
  }
}
