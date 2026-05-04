import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';

class ReorderPlaylistSongsUseCaseImpl implements ReorderPlaylistSongsUseCase {
  final PlaylistRepository _repository;
  const ReorderPlaylistSongsUseCaseImpl(this._repository);

  @override
  Future<void> call(ReorderPlaylistSongsParams params) =>
      _repository.reorderPlaylistSongs(
        playlistId: params.playlistId,
        songIds: params.songIds,
      );
}
