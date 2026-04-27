import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/home/domain/entities/home_data.dart';

abstract class GetHomeDataUseCase {
  Future<Either<Failure, HomeData>> call();
}
