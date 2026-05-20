import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_system_playlists_usecase.dart';

class GetSystemPlaylistsUseCaseImpl implements GetSystemPlaylistsUseCase {
  final PlaylistRepository _repository;

  const GetSystemPlaylistsUseCaseImpl(this._repository);

  @override
  Future<List<PlaylistSummary>> call() => _repository.getSystemPlaylists();
}
