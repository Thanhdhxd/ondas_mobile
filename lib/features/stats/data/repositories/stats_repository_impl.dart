import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/exceptions.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/stats/data/datasources/stats_remote_datasource.dart';
import 'package:ondas_mobile/features/stats/domain/entities/listening_time_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_artist_stats.dart';
import 'package:ondas_mobile/features/stats/domain/entities/top_song_stats.dart';
import 'package:ondas_mobile/features/stats/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDatasource _remoteDatasource;

  const StatsRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, ListeningTimeStats>> getListeningTime() async {
    try {
      final result = await _remoteDatasource.getListeningTime();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopSongStats>>> getTopSongs({int limit = 10}) async {
    try {
      final result = await _remoteDatasource.getTopSongs(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopArtistStats>>> getTopArtists({int limit = 10}) async {
    try {
      final result = await _remoteDatasource.getTopArtists(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
