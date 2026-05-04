abstract class AddSongToPlaylistUseCase {
  Future<void> call({required String playlistId, required String songId});
}
