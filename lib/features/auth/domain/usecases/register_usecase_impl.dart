import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/register_usecase.dart';

class RegisterUseCaseImpl implements RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
  }
}
