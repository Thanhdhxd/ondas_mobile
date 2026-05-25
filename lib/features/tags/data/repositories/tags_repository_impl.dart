import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/tags/data/datasources/tags_remote_datasource.dart';
import 'package:ondas_mobile/features/tags/domain/entities/tag.dart';
import 'package:ondas_mobile/features/tags/domain/repositories/tags_repository.dart';

class TagsRepositoryImpl implements TagsRepository {
  final TagsRemoteDatasource _datasource;

  const TagsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Tag>>> getTags({String? type}) async {
    try {
      final result = await _datasource.getTags(type: type);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PageResult<Tag>>> searchTags({
    required String query,
    String mode = 'contains',
    int page = 0,
    int size = 20,
  }) async {
    try {
      final result = await _datasource.searchTags(
        query: query,
        mode: mode,
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
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedFailure();
    final message = e.response?.data?['message'] ?? e.message ?? 'Network error';
    return ServerFailure(message: message as String, statusCode: statusCode);
  }
}
