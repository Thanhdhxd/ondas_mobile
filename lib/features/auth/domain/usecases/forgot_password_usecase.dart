import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class ForgotPasswordUseCase {
  Future<Either<Failure, void>> call(ForgotPasswordParams params);
}

class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}
