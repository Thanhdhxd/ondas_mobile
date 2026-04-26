import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';

abstract class ChangePasswordUseCase {
  Future<Either<Failure, void>> call(ChangePasswordParams params);
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
