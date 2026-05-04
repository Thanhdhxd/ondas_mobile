import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/get_library_playlists_usecase.dart';

class GetLibraryPlaylistsUseCaseImpl implements GetLibraryPlaylistsUseCase {
  final PlaylistRepository _repository;
  const GetLibraryPlaylistsUseCaseImpl(this._repository);

  @override
  Future<List<PlaylistSummary>> call() => _repository.getLibraryPlaylists();
}
