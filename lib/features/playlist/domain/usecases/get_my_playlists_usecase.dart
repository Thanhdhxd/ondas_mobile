import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';

class GetMyPlaylistsParams {
  final int page;
  final int size;

  const GetMyPlaylistsParams({this.page = 0, this.size = 20});
}

abstract class GetMyPlaylistsUseCase {
  Future<Either<Failure, PageResult<Playlist>>> call(
      GetMyPlaylistsParams params);
}
