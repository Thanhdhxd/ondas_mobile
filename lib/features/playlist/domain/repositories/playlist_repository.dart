import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';

abstract class PlaylistRepository {
  /// Returns current user's playlists. Each item includes [PlaylistSummary.containsSong]
  /// to reflect whether [songId] is already in the playlist.
  Future<List<PlaylistSummary>> getMyPlaylists({required String songId});

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  });

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  });

  /// Creates a new playlist. If [coverImageUrl] is provided, downloads the image
  /// and uploads it as the playlist cover.
  Future<PlaylistSummary> createPlaylist({
    required String name,
    String? coverImageUrl,
  });

  Future<List<PlaylistSummary>> getLibraryPlaylists();
  Future<PlaylistDetail> getPlaylistDetail(String id);
  Future<void> updatePlaylist({required String id, required String name});
  Future<void> deletePlaylist(String id);
  Future<void> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  });
}
