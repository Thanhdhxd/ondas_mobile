import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_failure_mapper.dart';
import 'package:ondas_mobile/features/home/domain/entities/song_summary.dart';
import 'package:ondas_mobile/features/songs/data/datasources/songs_remote_datasource.dart';
import 'package:ondas_mobile/features/songs/domain/repositories/songs_repository.dart';

class SongsRepositoryImpl implements SongsRepository {
  final SongsRemoteDatasource _datasource;

  const SongsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PageResult<SongSummary>>> getSongs({
    String? artistId,
    String? albumId,
    int? genreId,
    List<int>? tagIds,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final result = await _datasource.getSongs(
        artistId: artistId,
        albumId: albumId,
        genreId: genreId,
        tagIds: tagIds,
        page: page,
        size: size,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    return DioFailureMapper.map(
      e,
      notFoundMessage: 'Not found',
    );
  }
}
