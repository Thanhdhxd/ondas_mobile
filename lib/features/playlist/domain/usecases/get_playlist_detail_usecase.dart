import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

abstract class GetPlaylistDetailUseCase {
  Future<Either<Failure, Playlist>> call(String id);
}
