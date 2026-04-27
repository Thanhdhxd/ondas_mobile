import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_mobile/features/playlist/domain/entities/playlist.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDatasource _datasource;

  const PlaylistRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PageResult<Playlist>>> getMyPlaylists({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final result =
          await _datasource.getMyPlaylists(page: page, size: size);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> createPlaylist(
      CreatePlaylistParams params) async {
    try {
      final result = await _datasource.createPlaylist(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> getPlaylistDetail(String id) async {
    try {
      final result = await _datasource.getPlaylistDetail(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> updatePlaylist(
      UpdatePlaylistParams params) async {
    try {
      final result = await _datasource.updatePlaylist(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String id) async {
    try {
      await _datasource.deletePlaylist(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> addSongToPlaylist(
      AddSongToPlaylistParams params) async {
    try {
      final result = await _datasource.addSongToPlaylist(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Playlist>> removeSongFromPlaylist(
      RemoveSongFromPlaylistParams params) async {
    try {
      final result = await _datasource.removeSongFromPlaylist(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedFailure();
    if (statusCode == 404) {
      return NotFoundFailure(
          message: e.response?.data?['message'] as String? ?? 'Not found');
    }
    final message = e.response?.data?['message'] as String? ??
        e.message ??
        'Network error';
    return ServerFailure(message: message, statusCode: statusCode);
  }
}
