import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_detail.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist_summary.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDatasource _datasource;

  const PlaylistRepositoryImpl(this._datasource);

  @override
  Future<List<PlaylistSummary>> getMyPlaylists({required String songId}) {
    return _datasource.getMyPlaylists(songId: songId);
  }

  @override
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) {
    return _datasource.addSongToPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
  }

  @override
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) {
    return _datasource.removeSongFromPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
  }

  @override
  Future<PlaylistSummary> createPlaylist({
    required String name,
    String? coverImageUrl,
  }) {
    return _datasource.createPlaylist(name: name, coverImageUrl: coverImageUrl);
  }

  @override
  Future<List<PlaylistSummary>> getLibraryPlaylists() =>
      _datasource.getLibraryPlaylists();

  @override
  Future<PlaylistDetail> getPlaylistDetail(String id) =>
      _datasource.getPlaylistDetail(id);

  @override
  Future<void> updatePlaylist({required String id, required String name}) =>
      _datasource.updatePlaylist(id: id, name: name);

  @override
  Future<void> deletePlaylist(String id) => _datasource.deletePlaylist(id);

  @override
  Future<void> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) =>
      _datasource.reorderPlaylistSongs(playlistId: playlistId, songIds: songIds);
}
