import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/change_password_usecase.dart';

class ChangePasswordUseCaseImpl implements ChangePasswordUseCase {
  final ProfileRepository _repository;

  const ChangePasswordUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
