import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';

class CreatePlaylistUseCaseImpl implements CreatePlaylistUseCase {
  final PlaylistRepository _repository;

  const CreatePlaylistUseCaseImpl(this._repository);

  @override
  Future<PlaylistSummary> call(CreatePlaylistParams params) {
    return _repository.createPlaylist(
      name: params.name,
      coverImageUrl: params.coverImageUrl,
    );
  }
}
