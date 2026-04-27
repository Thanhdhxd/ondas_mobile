import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';

class GetMyPlaylistsUseCaseImpl implements GetMyPlaylistsUseCase {
  final PlaylistRepository _repository;

  const GetMyPlaylistsUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, PageResult<Playlist>>> call(
          GetMyPlaylistsParams params) =>
      _repository.getMyPlaylists(page: params.page, size: params.size);
}
