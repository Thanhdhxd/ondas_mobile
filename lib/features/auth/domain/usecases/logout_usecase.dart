import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class LogoutUseCase {
  Future<Either<Failure, void>> call();
}
