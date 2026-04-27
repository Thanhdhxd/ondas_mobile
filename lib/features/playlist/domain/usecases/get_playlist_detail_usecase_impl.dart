import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';

class GetPlaylistDetailUseCaseImpl implements GetPlaylistDetailUseCase {
  final PlaylistRepository _repository;

  const GetPlaylistDetailUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, Playlist>> call(String id) =>
      _repository.getPlaylistDetail(id);
}
