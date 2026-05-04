abstract class ReorderPlaylistSongsUseCase {
  Future<void> call(ReorderPlaylistSongsParams params);
}

class ReorderPlaylistSongsParams {
  final String playlistId;
  final List<String> songIds;
  const ReorderPlaylistSongsParams({
    required this.playlistId,
    required this.songIds,
  });
}
