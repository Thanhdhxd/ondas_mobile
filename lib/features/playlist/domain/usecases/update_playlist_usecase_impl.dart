import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/update_playlist_usecase.dart';

class UpdatePlaylistUseCaseImpl implements UpdatePlaylistUseCase {
  final PlaylistRepository _repository;
  const UpdatePlaylistUseCaseImpl(this._repository);

  @override
  Future<void> call(UpdatePlaylistParams params) =>
      _repository.updatePlaylist(id: params.id, name: params.name);
}
