import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/search/data/datasources/search_remote_datasource.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_result.dart';
import 'package:ondas_mobile/features/search/domain/entities/search_suggestion.dart';
import 'package:ondas_mobile/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDatasource _datasource;

  const SearchRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SearchResult>> search({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final result = await _datasource.search(query: query, page: page, size: size);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SearchSuggestion>> getSuggestions() async {
    try {
      final result = await _datasource.getSuggestions();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await _datasource.clearHistory();
      return const Right(null);
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
