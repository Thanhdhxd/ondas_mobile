import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/forgot_password_usecase.dart';

class ForgotPasswordUseCaseImpl implements ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(email: params.email);
  }
}
