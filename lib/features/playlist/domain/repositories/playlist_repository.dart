import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, PageResult<Playlist>>> getMyPlaylists({
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, Playlist>> createPlaylist(CreatePlaylistParams params);

  Future<Either<Failure, Playlist>> getPlaylistDetail(String id);

  Future<Either<Failure, Playlist>> updatePlaylist(UpdatePlaylistParams params);

  Future<Either<Failure, void>> deletePlaylist(String id);

  Future<Either<Failure, Playlist>> addSongToPlaylist(
      AddSongToPlaylistParams params);

  Future<Either<Failure, Playlist>> removeSongFromPlaylist(
      RemoveSongFromPlaylistParams params);
}

class CreatePlaylistParams {
  final String name;
  final String? description;
  final bool isPublic;

  const CreatePlaylistParams({
    required this.name,
    this.description,
    this.isPublic = false,
  });
}

class UpdatePlaylistParams {
  final String id;
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdatePlaylistParams({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
  });
}

class AddSongToPlaylistParams {
  final String playlistId;
  final String songId;

  const AddSongToPlaylistParams({
    required this.playlistId,
    required this.songId,
  });
}

class RemoveSongFromPlaylistParams {
  final String playlistId;
  final String songId;

  const RemoveSongFromPlaylistParams({
    required this.playlistId,
    required this.songId,
  });
}
