import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';

abstract class RemoveSongFromPlaylistUseCase {
  Future<Either<Failure, Playlist>> call(RemoveSongFromPlaylistParams params);
}
