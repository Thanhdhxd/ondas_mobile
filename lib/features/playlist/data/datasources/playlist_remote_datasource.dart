import 'package:ondas_mobile/features/playlist/data/models/playlist_detail_model.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_summary_model.dart';

abstract class PlaylistRemoteDatasource {
  Future<List<PlaylistSummaryModel>> getMyPlaylists({required String songId});

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  });

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  });

  Future<PlaylistSummaryModel> createPlaylist({
    required String name,
    String? coverImageUrl,
  });

  Future<List<PlaylistSummaryModel>> getLibraryPlaylists();
  Future<PlaylistDetailModel> getPlaylistDetail(String id);
  Future<void> updatePlaylist({required String id, required String name});
  Future<void> deletePlaylist(String id);
  Future<void> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  });
}
