import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';

class DeletePlaylistUseCaseImpl implements DeletePlaylistUseCase {
  final PlaylistRepository _repository;
  const DeletePlaylistUseCaseImpl(this._repository);

  @override
  Future<void> call(String playlistId) => _repository.deletePlaylist(playlistId);
}
