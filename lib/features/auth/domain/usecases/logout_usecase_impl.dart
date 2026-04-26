import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/logout_usecase.dart';

class LogoutUseCaseImpl implements LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
