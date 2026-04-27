import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';
import 'package:ondas_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:ondas_mobile/features/home/domain/usecases/get_home_data_usecase.dart';

class GetHomeDataUseCaseImpl implements GetHomeDataUseCase {
  final HomeRepository _repository;

  const GetHomeDataUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, HomeData>> call() => _repository.getHomeData();
}
