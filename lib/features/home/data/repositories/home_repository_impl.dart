import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/core/network/dio_failure_mapper.dart';
import 'package:ondas_mobile/features/home/data/datasources/home_remote_datasource.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';
import 'package:ondas_mobile/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource _datasource;

  const HomeRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, HomeData>> getHomeData() async {
    try {
      final result = await _datasource.getHomeData();
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
