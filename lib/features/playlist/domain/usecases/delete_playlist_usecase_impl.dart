import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/delete_playlist_usecase.dart';

class DeletePlaylistUseCaseImpl implements DeletePlaylistUseCase {
  final PlaylistRepository _repository;

  const DeletePlaylistUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      _repository.deletePlaylist(id);
}
