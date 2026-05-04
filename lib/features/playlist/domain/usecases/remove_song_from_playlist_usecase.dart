abstract class RemoveSongFromPlaylistUseCase {
  Future<void> call({required String playlistId, required String songId});
}
