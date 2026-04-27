import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_model.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';

abstract class PlaylistRemoteDatasource {
  Future<PageResult<PlaylistModel>> getMyPlaylists({int page, int size});

  Future<PlaylistModel> createPlaylist(CreatePlaylistParams params);

  Future<PlaylistModel> getPlaylistDetail(String id);

  Future<PlaylistModel> updatePlaylist(UpdatePlaylistParams params);

  Future<void> deletePlaylist(String id);

  Future<PlaylistModel> addSongToPlaylist(AddSongToPlaylistParams params);

  Future<PlaylistModel> removeSongFromPlaylist(
      RemoveSongFromPlaylistParams params);
}
