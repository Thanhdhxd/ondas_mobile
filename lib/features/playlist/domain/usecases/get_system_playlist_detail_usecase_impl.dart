import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_system_playlist_detail_usecase.dart';

class GetSystemPlaylistDetailUseCaseImpl implements GetSystemPlaylistDetailUseCase {
  final PlaylistRepository _repository;

  const GetSystemPlaylistDetailUseCaseImpl(this._repository);

  @override
  Future<PlaylistDetail> call(String id) =>
      _repository.getSystemPlaylistDetail(id);
}
