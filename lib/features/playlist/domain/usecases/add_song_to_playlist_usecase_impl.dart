import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:ondas_mobile/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';

class AddSongToPlaylistUseCaseImpl implements AddSongToPlaylistUseCase {
  final PlaylistRepository _repository;

  const AddSongToPlaylistUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, Playlist>> call(AddSongToPlaylistParams params) =>
      _repository.addSongToPlaylist(params);
}
