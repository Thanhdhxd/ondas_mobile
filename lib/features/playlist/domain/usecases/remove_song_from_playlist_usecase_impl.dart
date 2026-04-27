import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';

class RemoveSongFromPlaylistUseCaseImpl implements RemoveSongFromPlaylistUseCase {
  final PlaylistRepository _repository;

  const RemoveSongFromPlaylistUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, Playlist>> call(RemoveSongFromPlaylistParams params) =>
      _repository.removeSongFromPlaylist(params);
}
