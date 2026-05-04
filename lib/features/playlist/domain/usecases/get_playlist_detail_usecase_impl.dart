import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';

class GetPlaylistDetailUseCaseImpl implements GetPlaylistDetailUseCase {
  final PlaylistRepository _repository;
  const GetPlaylistDetailUseCaseImpl(this._repository);

  @override
  Future<PlaylistDetail> call(String playlistId) =>
      _repository.getPlaylistDetail(playlistId);
}
