import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';

abstract class LoginUseCase {
  Future<Either<Failure, User>> call(LoginParams params);
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
