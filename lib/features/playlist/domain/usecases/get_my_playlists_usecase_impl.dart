import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_my_playlists_usecase.dart';

class GetMyPlaylistsUseCaseImpl implements GetMyPlaylistsUseCase {
  final PlaylistRepository _repository;

  const GetMyPlaylistsUseCaseImpl(this._repository);

  @override
  Future<List<PlaylistSummary>> call({required String songId}) {
    return _repository.getMyPlaylists(songId: songId);
  }
}
