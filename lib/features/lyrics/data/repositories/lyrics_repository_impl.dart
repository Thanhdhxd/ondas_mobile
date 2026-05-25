import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/dio_failure_mapper.dart';
import 'package:ondas_mobile/features/lyrics/data/datasources/lyrics_remote_datasource.dart';
import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';
import 'package:ondas_mobile/features/lyrics/domain/repositories/lyrics_repository.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsRemoteDatasource _datasource;

  const LyricsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Lyrics>> getLyrics(String songId) async {
    try {
      final result = await _datasource.getLyrics(songId);
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
      notFoundMessage: 'Lyrics not found',
    );
  }
}
