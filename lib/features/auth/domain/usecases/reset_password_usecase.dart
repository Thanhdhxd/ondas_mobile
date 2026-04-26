import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class ResetPasswordUseCase {
  Future<Either<Failure, void>> call(ResetPasswordParams params);
}

class ResetPasswordParams {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}
