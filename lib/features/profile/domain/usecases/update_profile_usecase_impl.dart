import 'package:fpdart/fpdart.dart';
import 'package:ondas_mobile/core/error/failures.dart';
import 'package:ondas_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:ondas_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:ondas_mobile/features/profile/domain/usecases/update_profile_usecase.dart';

class UpdateProfileUseCaseImpl implements UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCaseImpl(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      displayName: params.displayName,
    );
  }
}
