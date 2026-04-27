import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/create_playlist_usecase.dart';

class CreatePlaylistUseCaseImpl implements CreatePlaylistUseCase {
  final PlaylistRepository _repository;

  const CreatePlaylistUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, Playlist>> call(CreatePlaylistParams params) =>
      _repository.createPlaylist(params);
}
