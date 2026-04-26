import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/auth/domain/entities/user.dart';

abstract class RegisterUseCase {
  Future<Either<Failure, User>> call(RegisterParams params);
}

class RegisterParams {
  final String fullName;
  final String email;
  final String password;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
  });
}
