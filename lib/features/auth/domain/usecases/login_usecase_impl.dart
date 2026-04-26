import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/login_usecase.dart';

class LoginUseCaseImpl implements LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
