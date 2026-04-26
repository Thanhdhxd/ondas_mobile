import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_mobile/features/auth/domain/usecases/reset_password_usecase.dart';

class ResetPasswordUseCaseImpl implements ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      otp: params.otp,
      newPassword: params.newPassword,
    );
  }
}
