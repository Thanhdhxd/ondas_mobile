import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class ClearPlayHistoryUseCase {
  Future<Either<Failure, void>> call();
}
